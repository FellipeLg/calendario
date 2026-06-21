class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_group
    @group = Group.find_by!(share_token: params[:share_token])
  end

  def redirect_to_group(notice: nil, alert: nil)
    redirect_to group_calendar_path(@group.share_token), notice:, alert:
  end
end
