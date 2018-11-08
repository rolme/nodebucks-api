class UsersController < ApplicationController
  before_action :authenticate_request, only: [:balance, :update, :destroy, :referrer, :password_confirmation, :verification_image]
  before_action :authenticate_admin_request, only: [:disable, :enable, :index, :impersonate, :show, :update_affiliates, :remove_affiliates]
  before_action :find_user, only: [:update, :profile, :update_affiliates, :remove_affiliates]

  def callback
    @user = nil
    if user_params['facebook'].present?
      @user   = User.find_by(facebook: user_params[:facebook])
      @user ||= User.find_by(email: user_params[:email])
      @user&.update_attribute(:facebook, user_params[:facebook]) if @user&.facebook.blank?
    elsif user_params['google'].present?
      @user = User.find_by(google: user_params[:google])
      @user ||= User.find_by(email: user_params[:email])
      @user&.update_attribute(:google, user_params[:google]) if @user&.google.blank?
    elsif user_params['linkedin'].present?
      @user = User.find_by(linkedin: user_params[:linkedin])
      @user ||= User.find_by(email: user_params[:email])
      @user&.update_attribute(:linkedin, user_params[:linkedin]) if @user&.linkedin.blank?
    end

    if @user.present?
      avatar = Utils.download(@user.id, params[:user][:avatar])
      @user.update_attribute(:avatar, avatar)
      render json: { status: :ok, token: generate_token, message: 'User logged in.' }
    else
      @user = User.new(user_params)
      @user.set_upline(referrer_params[:referrer_affiliate_key])

      if @user.save
        avatar = Utils.download(@user.id, params[:user][:avatar])
        @user.update_attribute(:avatar, avatar)
        render json: { status: :ok, token: generate_token, message: 'User account created.' }
        if ENV['RAILS_ENV'] == 'development'
          RegistrationMailer.send_verify_email(@user).deliver_now
        else
          RegistrationMailer.send_verify_email(@user).deliver_later
        end
      else
        render json: { status: 'error', message: @user.errors.full_messages.join(', ')}
      end
    end
  end

  def index
    if(params[:verification_pending_users].present? && params[:verification_pending_users].to_bool)
      @users = User.where.not(email: nil).verifications_pending
    elsif params[:nonadmin].present? && params[:nonadmin].to_bool
      @users = User.where.not(email: nil).where(admin: [false, nil])
    else
      @users = User.where.not(email: nil)
    end
  end

  def login
    authenticate params[:email], params[:password]
  end

  def update
    if !@user.authenticate(params[:current_password])
      render json: { status: 'error', message: 'Current password is incorrect.'}
      return
    end

    if @user.update(user_params)
      render json: { status: :ok, token: generate_token, message: 'User account updated.' }
    else
      render json: { status: 'error', message: @user.errors.full_messages.join(', ')}
    end
  end

  def profile
    if @user.update(user_params)
      render json: { status: :ok, token: generate_token, message: 'User profile updated.' }
    else
      render json: { status: 'error', message: @user.errors.full_messages.join(', ')}
    end
  end

  def reset
    @user = User.find_by(email: params[:email])
    if @user.present?
      @user.reset!
      if ENV['RAILS_ENV'] == 'development'
        RegistrationMailer.send_reset_email(@user).deliver_now
      else
        RegistrationMailer.send_reset_email(@user).deliver_later
      end
      render json: { status: :ok, message: 'Reset password email sent.' }
    else
      render json: { status: 'error', message: 'Email could not be found.' }
    end
  end

  def reset_password
    @user = User.find_by(reset_token: params[:user_slug])
    if @user.blank? || !@user.token_valid?
      @user&.delete_token!
      render json: { status: 'error', message: 'Reset token has expired' }
      return
    end

    if @user.change_password!(user_params[:password], user_params[:password_confirmation])
      render json: { status: :ok, token: generate_token, message: 'Password has been updated.' }
    else
      render json: { status: 'error', message: @user.error.full_messages.join(', ') }
    end
  end

  def admin_login
    user  = User.find_by(email: params[:email], admin: true)
    @user = user&.authenticate(params[:password])
    if @user.present?
      render json: {
        token: generate_token,
        message: 'Login Successful'
      }
    else
      render json: { status: 'error', message: 'Email/Password is incorrect.' }, status: :unauthorized
    end
  end

  def balance
    @user = current_user
    render :show
  end

  def referrer
    @user = current_user
  end

  def create
    @user = User.new(user_params)

    @user.set_upline(referrer_params[:referrer_affiliate_key])
    if @user.save
      if ENV['RAILS_ENV'] == 'development'
        RegistrationMailer.send_verify_email(@user).deliver_now
      else
        RegistrationMailer.send_verify_email(@user).deliver_later
      end
      render json: { status: :ok, token: generate_token, message: 'User account created.' }
    else
      render json: { status: 'error', message: @user.errors.full_messages.join(', ')}
    end
  end

  def confirm
    @user = User.find_by(slug: params[:user_slug])
    if @user.present?
      @user.update_attribute(:confirmed_at, DateTime.current)
      render json: { status: :ok, token: generate_token, message: 'User registration confirmed.' }
    else
      render json: { status: 'error', message: "User could not be found."}
    end
  end

  def verify
    @user = User.find_by(slug: params[:user_slug])
    if @user&.verify_email!
      render json: { status: :ok, token: generate_token, message: 'User email has been verified.' }
    else
      render json: { status: 'error', message: (@user) ? @user.errors.full_messages.join(', ') : 'User cannot be found.' }
    end
  end

  def destroy
    if (current_user.slug == params[:slug])
      current_user.delete
      render json: { status: :ok, message: 'User account has been removed.' }
    else
      render json: { status: 'error', message: 'You cannot delete this account.' }
    end
  end

  def show
    @user = User.find_by(slug: params[:slug])
  end

  def authorized
    command = AuthorizedToken.call(params[:t])

    if command.success?
      render json: {
        token: params[:t],
        message: 'Valid Token'
      }
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  def password_confirmation
    user = User.find_by(slug: params[:user_slug])
    render json: { status: :ok, valid: user.authenticate(params[:user][:password]).present? }
  end

  def verification_image
    user = User.find_by(slug: params[:user_slug])
    if user.update(verification_image: params[:user][:verification_image], verification_status: :pending)
      IdVerificationMailer.send_email(user).deliver_later
      render json: { status: :ok, message: 'Photo successfully uploaded.' }
    else
      render json: { status: :error, message: user.errors.full_messages.join(', ') }
    end
  end

  def approved
    user = User.find_by(slug: params[:user_slug])
    if user.update(verified_at: Time.zone.now, verification_status: :approved)
      render json: { status: :ok, message: 'ID verification is successfully approved.' }
    else
      render json: { status: :error, message: user.errors.full_messages.join(', ') }
    end
  end

  def denied
    user = User.find_by(slug: params[:user_slug])
    if user.update(verification_status: :denied)
      render json: { status: :ok, message: 'ID verification is successfully denied.' }
    else
      render json: { status: :error, message: user.errors.full_messages.join(', ') }
    end
  end

  def impersonate
    @user = User.find_by_slug(params[:slug])
    render json: { status: :ok, token: generate_token }
  end

  def enable
    @user = User.find_by(slug: params[:user_slug])
    @user.enable!
    render json: { status: :ok, message: 'User account successfully enabled.', token: generate_token }
  end

  def disable
    @user = User.find_by(slug: params[:user_slug])
    @user.disable!
    render json: { status: :ok, message: 'User account successfully disabled.', token: generate_token }
  end

  def enable_2fa
    @user = User.find_by(slug: params[:user_slug])
    if(@user.update(two_fa_secret: params[:user][:two_fa_secret]))
      render json: { status: :ok, message: '2FA is successfully enabled.', token: generate_token }
    else
      render json: { status: :error, message: 'Error while enabling 2FA.' }
    end
  end

  def disable_2fa
    @user = User.find_by(slug: params[:user_slug])
    if(@user.update(two_fa_secret: nil))
      render json: { status: :ok, message: '2FA is successfully disabled.', token: generate_token }
    else
      render json: { status: :error, message: 'Error while disabling 2FA.' }
    end
  end

  def secret_2fa
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password]).present?
      if user.two_fa_secret.present?
        render json: { status: :ok, enabled_2fa: true, secret: user.two_fa_secret }
      else
        render json: { status: :ok, enabled_2fa: false }
      end
    else
      render json: { status: :error, message: 'Invalid credentials' }
    end
  end

  def update_affiliates
    @user.update_affiliates(params[:tier1_slug])
    render :show
  end

  def remove_affiliates
    @user.remove_affiliates
    render :show
  end

protected

  def user_params
    params.require(:user).permit(
      :address,
      :avatar,
      :city,
      :country,
      :email,
      :facebook,
      :first,
      :google,
      :last,
      :linkedin,
      :new_email,
      :nickname,
      :password,
      :password_confirmation,
      :reward_notification_on,
      :state,
      :zipcode,
    )
  end

  def referrer_params
    params.permit(:referrer_affiliate_key)
  end

private

  def authenticate(email, password)
    command = AuthenticateUser.call(email, password)

    if command.success?
      @user = command.user
      render json: {
        token: command.result,
        message: 'Login Successful'
      }
    else
      render json: { status: 'error', message: command.errors[:user_authentication] }, status: :unauthorized
    end
  end

  def find_user
    @user = User.find_by(slug: params[:slug] || params[:user_slug])
    if @user.blank?
      render json: { status: 'error', message: 'Could not find user.' }
      return
    end
  end

  # TODO: This code also exists in authenticate_user.rb
  def generate_token
    JsonWebToken.encode({
      admin: @user.admin,
      address: @user.address,
      avatar: @user.avatar,
      city: @user.city,
      confirmedAt: @user.confirmed_at&.to_formatted_s(:db),
      country: @user.country,
      createdAt: @user.created_at.to_formatted_s(:db),
      email: @user.email,
      enabled: @user.enabled,
      enabled2FA: @user.two_fa_secret.present?,
      first: @user.first,
      fullName: @user.full_name,
      last: @user.last,
      newEmail: @user.new_email,
      nickname: @user.nickname,
      rewardNotificationOn: @user.reward_notification_on,
      slug: @user.slug,
      state: @user.state,
      updatedAt: @user.updated_at.to_formatted_s(:db),
      zipcode: @user.zipcode,
      verified: @user.verified_at,
      verificationStatus: @user.verification_status,
      verificationImage: @user.verification_image
    })
  end
end
