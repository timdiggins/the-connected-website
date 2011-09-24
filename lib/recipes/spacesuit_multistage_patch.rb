#adapted from https://github.com/ntalbott/spacesuit/blob/master/lib/spacesuit/recipes/multistage_patch.rb

on :load do
  if stages.include?(ARGV.first)
    # Execute the specified stage so that recipes required in stage can contribute to task list
    find_and_execute_task(ARGV.first) if ARGV.any?{ |option| option =~ /-T|--tasks|-e|--explain/ }
  else
    # Execute the default stage so that recipes required in stage can contribute tasks
    find_and_execute_task(default_stage) if exists?(:default_stage)
  end
end
