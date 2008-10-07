module AuthenticatedSystem
  protected
    def logged_in?
      current_user != :false
    end
    
    def logged_in_as_editor?
      logged_in? && current_user.editor
    end

    def logged_in_as_admin?
      logged_in? && current_user.admin
    end

    def current_user
      @current_user ||= (session[:user] && User.find_by_id(session[:user])) || :false
    end
    
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end
    
    def authorized?
      true
    end

    def login_required
      username, password = get_auth_data
      self.current_user ||= User.authenticate(username, password) || :false if username && password
      logged_in? && authorized? ? true : access_denied
    end
    
    def editor_login_required
      special_login_required { current_user.editor }
    end
    
    def admin_login_required
      special_login_required { current_user.admin }
    end
    
    def access_denied
      respond_to do |accepts|
        accepts.html {
          store_location
          flash[:warning] = "You must login to access that part of the site."
          redirect_to login_url
        }
        accepts.xml {
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "HTTP Basic: Access denied.", :status => '401 Unauthorized'
        }
      end
      false
    end  
    
    def store_location(location=nil)
      session[:return_to] = location ? location : request.request_uri
    end
    
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :logged_in_as_editor?, :logged_in_as_admin?
    end

    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_user = user
        user.track_login
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        flash[:notice] = "Logged in successfully"
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
    
    def special_login_required(&block)
      return access_denied unless logged_in? && authorized?
      return true if yield

      flash[:error] = "You do not have permission to access that part of the site."
      redirect_to root_url
      false
    end
    
end
