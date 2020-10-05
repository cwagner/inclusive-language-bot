# frozen_string_literal: true

source 'https://gems.vip.global.square' do
  gem 'bundler', '~> 2.1'
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.9'
  gem 'rubocop', '>= 0.88'
  gem 'rubyprobot', path: '../square-github-apps/rubyprobot'

  # These gems are necessary if you're debugging with VSCode. Run `bundle install --with debug_vscode`
  group :debug_vscode, optional: true do
    gem 'debase'
    gem 'ruby-debug-ide'
  end
end