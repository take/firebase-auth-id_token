# Firebase Auth ID token verifier

## Installation

Add the following line to your Gemfile:

```
gem 'firebase-auth-id_token-verifier'
```

Then run `bundle install`

Set the following config code as `config/initializers/firebase-auth-id_token-verifier.rb`

```
Firebase::Auth::IDToken::Verifier.configure do |config|
  config.firebase_project_id = 'YOUR_FIREBASE_PROJECT_ID'
end
```

`YOUR_FIREBASE_PROJECT_ID` could be found at https://console.firebase.google.com

## Usage

### Rails API

```
class ApplicationController < ActionController::API
  before_action :verify_auth_token!
  before_action :authenticate_user!

  protected

  def authenticate_user!
    User.find_by!(uid: @auth_token_payload['sub'])
  rescue ActiveRecord::RecordNotFound
    head :unauthorized
  end

  def verify_auth_token!
    @auth_token_payload = Firebase::Auth::IDToken::Verifier.new(auth_id_token).verify!
  # You should refetch ID token on the client side if you receive this 401
  rescue Firebase::Auth::IDToken::Expired
    render json: { error: { message: 'Auth ID token expired' } }, status: :unauthorized
  rescue Firebase::Auth::IDToken::Error
    # Notifying to Bugsnag/Sentry here will be nice
    head :unauthorized
  end

  private

  def auth_id_token
    request.headers['Authorization']
  end
end
```

```
class UsersController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    @user = User.new(user_params)

    if @user.save
      head :created
    else
      render json: { errors: @user.errors.full_messages }
    end
  end

  private

  def user_params
    params.require(:user)
          .permit(:name)
          .merge(firebase_auth_uid: @auth_token_payload['sub'])
  end
end
```

## Errors

TBD

## FAQs

Q. How to retrieve user informations?
A. Best way right now would be by using [googleapis/google-api-ruby-client](https://github.com/googleapis/google-api-ruby-client)'s `Google::Apis::IdentitytoolkitV3::GetAccountInfoRequest``. [Sample code]()
