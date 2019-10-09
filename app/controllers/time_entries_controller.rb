class TimeEntriesController < ApplicationController

  # POST /time_entries
  def create
    respond_to do |format|
      if params["time_entry"]["time_recordable_type"] == "Staff"
        found_staff = Staff.find_by(pin_number: params["pin_number"])

        if found_staff.present?
          record_type = params["on_clock"].present? ? TimeEntryType[:entry] : TimeEntryType[:exit]
          @time_entry = TimeEntry.new(time_entry_params.merge({ time: Time.zone.now, record_type: record_type }))
        end
      elsif params["time_entry"]["time_recordable_type"] == "Child"
        record_type = params["on_clock"].present? ? TimeEntryType[:entry] : TimeEntryType[:exit]
        @time_entry = TimeEntry.new(time_entry_params.merge({ time: Time.zone.now, record_type: record_type }))
      end

      if @time_entry.present? && @time_entry.save!
        format.js { render json: { clocked_in: @time_entry.time_recordable.on_clock? } }
      else
        format.json { render json: @time_entry.present? ? @time_entry.errors : "PIN Number Incorrect", status: :unprocessable_entity }
      end
    end
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(:time_recordable_id, :time_recordable_type, :location_id)
  end
end
