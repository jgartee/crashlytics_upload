guard :rspec, cmd: "bundle exec rspec -f doc" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)
  clearing:on

  # Feel free to open issues for suggestions and improvements

    # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)
  #watch('upload_file_tracker.rb') {rspec.spec_dir }
  watch('\.(rb)$') {rspec.spec_dir }

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

end
