class TimeEntriesController < ApplicationController

  # POST /time_entries
  def create
    record_type = params["on_clock"].present? ? "entry" : "exit"
    @time_entry = TimeEntry.new(time_entry_params.merge({ time: Time.zone.now, record_type: record_type }))

    respond_to do |format|
      if @time_entry.save
        format.js
      else
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_entry_params
      params.require(:time_entry).permit(:time_recordable_id, :time_recordable_type, :location_id)
    end
end
