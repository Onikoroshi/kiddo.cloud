class Children::AttendanceDisplayController < ApplicationController
  layout "dkk_staff_dashboard"
  before_action :guard_center!

  # GET /interviews
  def index
    if params[:location_id].present?
      @location = Location.find(params[:location_id])
    else
      @location = @center.default_location
    end

    @enrollments = @location.enrollments.alive.paid.for_date(Time.zone.today)
    @programs = @enrollments.programs

    @program = Program.find_by(id: params[:program_id])

    @enrollments = @enrollments.by_program_on_date(@program, Time.zone.today) if @program.present?
  end

  def send_tardy_notification
    @child = Child.find(params[:id])

    error_message = ""
    notice_message = ""

    error_message = @child.tardy_notification_blocker

    if error_message.present?
      flash[:error] = error_message
    else
      TransactionalMailer.late_checkin_alert(@child.account, @child).deliver_now
      @child.late_checkin_notifications.create(
        account: @child.account,
        sent_at: Time.zone.now,
        sent_to_email: @child.account.all_emails.join(", "),
      )
      TransactionalMailer.late_notifications_report([@child]).deliver_now
      flash[:notice] = "Tardy notification email sent to #{@child.account.all_emails.to_sentence} for #{@child.full_name}"
    end

    redirect_to children_attendance_display_index_path
  end
end
