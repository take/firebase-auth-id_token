# Firebase Auth ID token verifier

## Installation

Add the following line to your Gemfile:

```ruby
gem 'firebase-auth-id_token'
```

Then run `bundle install`

Set the following config code as `config/initializers/firebase-auth-id_token.rb`

```ruby
Firebase::Auth::IDToken.configure do |config|
  config.project_id = 'YOUR_FIREBASE_PROJECT_ID'
end
```

`YOUR_FIREBASE_PROJECT_ID` could be found at https://console.firebase.google.com

## Usage

Use `Firebase::Auth::IDToken#verify!` as below

### Rails API

```ruby
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
    @auth_token_payload, _ = Firebase::Auth::IDToken.new(auth_id_token).verify!
  # You should refetch ID token on the client side if you receive this 401
  rescue Firebase::Auth::IDToken::Error::Expired
    render json: { error: { message: 'Auth ID token expired' } }, status: :unauthorized
  rescue Firebase::Auth::IDToken::Error::VerificationFail
    # Notifying to Bugsnag/Sentry here will be nice
    head :unauthorized
  end

  private

  def auth_id_token
    request.headers['Authorization']
  end
end
```

```ruby
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

### Important ones

* `Firebase::Auth::IDToken::Error::ProjectIdNotSet` - raised if you haven't set `project_id`
* `Firebase::Auth::IDToken::Error::Expired` - raised when the given token is expired, you should return an error code(e.g. 401) to the client so the client can refetch a new token

### Others

The following errors will basically be raised when the token is either unable to decode, or invalid.
These shouldn't be raised in normal use case, so rescuing the parent class(which is `~::VerificationFail`) and notifying to error monitoring service might be good(see `Usage` section).

* `Firebase::Auth::IDToken::Error::Expired`
* `Firebase::Auth::IDToken::Error::CannotDecode`
* `Firebase::Auth::IDToken::Error::IncorrectAlgorithm`
* `Firebase::Auth::IDToken::Error::InvalidIat`
* `FireBase::Auth::IDToken::Error::InvalidAud`
* `FireBase::Auth::IDToken::Error::InvalidIssuer`
* `FireBase::Auth::IDToken::Error::InvalidSub`
* `FireBase::Auth::IDToken::Error::InvalidAuthTime`

## FAQs

* Q. How to retrieve user informations?
* A. Best way right now would be by using [googleapis/google-api-ruby-client](https://github.com/googleapis/google-api-ruby-client)'s `Google::Apis::IdentitytoolkitV3::GetAccountInfoRequest`. [Sample code]()
