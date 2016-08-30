
# Penn Paper Size #


App to calculate 15th C. paper sizes based on page dimensions.

## Installation ##

Clone, install gems, and start the application:

```
git clone git@github.com:demery/paper-sizer.git
cd paper-sizer
bundle install  # see below on bundler
rackup          # start the app
```
Go to <http://localhost:9292> to see the app!

### Bundler ###
To install all [bundler](bundler):

```
gem install bundler
```

[bundler]: http://bundler.io  "bundler.io"

## Filling in the code ##

The work is done by `app.rb`. The user inputs data on the form at the `/`
route (the `views/index.erb` template):

```ruby
get '/' do
  erb :index
end
```

When user submits the form the data is posted to the `/sizeit` route:

```ruby
post '/sizeit' do
  erb :sizeit, locals: params
end
```

The page displayed to the user is built from the `views/sizeit.erb` template.

To add functionality to the application edit the `/sizeit` action and the
`views/sizeit.erb` template.
