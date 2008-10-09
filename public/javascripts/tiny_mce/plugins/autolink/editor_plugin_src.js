/**
 * $Id: editor_plugin_src.js 201 2007-02-12 15:56:56Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright © 2004-2008, Moxiecode Systems AB, All rights reserved.
 */
(function() {
	// Load plugin specific language pack
	tinymce.PluginManager.requireLangPack('autolink');

	tinymce.create('tinymce.plugins.AutolinkPlugin', {
		/**
		 * Initializes the plugin, this will be executed after the plugin has been created.
		 * This call is done before the editor instance has finished it's initialization so use the onInit event
		 * of the editor instance to intercept that event.
		 *
		 * @param {tinymce.Editor} ed Editor instance that the plugin is initialized in.
		 * @param {string} url Absolute URL to where the plugin is located.
		 */
		init : function(ed, url) {

			ed.onKeyUp.add(function(ed, e) {
				if (e.keyCode ==32){
					var node = $(ed.selection.getNode());
					if (node.nodeName=="A"){
						//console.debug("not dealing inside a");
						return;
					}
					if (window.getSelection) {
						//this is Firefox stuff
						//console.debug("node:"+node.getOuterHtml)
						var rng= ed.selection.getRng();
						var container = rng.commonAncestorContainer;
						if (container.nodeType != container.TEXT_NODE){
							//console.debug("not dealign with non text node");
							return;
						}
						var txt = container.data;
						//console.debug("sel:"+txt);
						var space = rng.endOffset;
						var i=space-1;
						while(i>0){
							i--;
							var ch = txt.substring(i,i+1);
							//console.debug("ch :"+ch);
							if (ch == " "){
								i++;
								break;
							}
						}
						word = txt.substring(i,rng.endOffset-1);
						//console.debug("word:'"+word+"'");
						if (word.match(/^http:\/\/.+$/)){
							rng.setStart(container,0);
							rng.setEnd(container,txt.length);
							pre = txt.substring(0,i);
							post = txt.substring(space-1, txt.length+1);
							ed.selection.setContent(pre+"<a href='"+word+"'>"+word+"</a>"+post);
							var rng2 = ed.selection.getRng();
							var offset = rng2.endOffset - txt.length + space;
							/*console.debug("rng2.endOffset:"+rng2.endOffset);
							console.debug("txt.length:"+txt.length);
							console.debug("space:"+space);
							console.debug("offset:"+offset);
							*/
							rng2.setStart(rng2.endContainer, offset);
							rng2.collapse(true);
						}
					}
					/*for(var i=0;i<node.childNodes.length;i++){
						var childNode = node.childNodes[i];
						if(childNode.nodeType != childNode.TEXT_NODE){
							console.debug("not dealign with non text node");
							continue;
						}
						
						var word = "words[w]";
						if (word.match(/^http:\/\/.*$/)){
							console.debug("word matches!");
						} else {
							
						}
						/*console.debug("node["+i+"] ="+childNode);
						console.debug("node["+i+"]d="+childNode.data);
						for (var i in childNode){
							console.debug("  "+i+":"+childNode[i]);
						}
					}*/
					//d.selection.setContent("<a href='aha'>aha</a>");
					
			}
			});
		},


		/**
		 * Returns information about the plugin as a name/value array.
		 * The current keys are longname, author, authorurl, infourl and version.
		 *
		 * @return {Object} Name/value array containing information about the plugin.
		 */
		getInfo : function() {
			return {
				longname : 'Autolink plugin',
				author : 'tim@red56.co.uk',
				authorurl : 'http://red56.co.uk',
				infourl : 'http://red56.co.uk/projects/tinymce_autolink_plugin',
				version : "1.0"
			};
		}
	});

	// Register plugin
	tinymce.PluginManager.add('autolink', tinymce.plugins.AutolinkPlugin);
})();