class TenantBackupsController < MortimerController
  #
  # defined in the batch_actions concern
  skip_before_action :set_batch, only: %i[ new index destroy] # new b/c of modal
  #
  # defined in the resourceable concern
  skip_before_action :set_resource, only: %i[ new show edit update destroy ]
  skip_before_action :set_filter, only: %i[ new index destroy ] # new b/c of modal
  skip_before_action :set_resources, only: %i[ index destroy ]
  skip_before_action :set_resources_stream
  skip_before_action :set_user_resources_stream, only: %i[ index ]

  #
  # GET /tenant_backups/tenant_1_20251121071300.tar.gz
  #
  def download
    filename = params[:filename]

    # Security: validate filename format (tenant_ID_TIMESTAMP.tar.gz)
    unless filename.match?(/\Atenant_\d+_\d{14}\.tar\.gz\z/)
      return head :not_found
    end

    file_path = Rails.root.join("storage", "tenant_backups", filename)

    # Check file exists
    unless File.exist?(file_path)
      return head :not_found
    end

    # Security: ensure user belongs to the tenant in the filename
    tenant_id = filename.match(/tenant_(\d+)_/)[1].to_i
    unless Current.tenant&.id == tenant_id
      return head :forbidden
    end

    send_file file_path,
              filename: filename,
              type: "application/gzip",
              disposition: "attachment"
  end

  def restore
    redirect_to root_path, alert: "Restore functionality is not implemented yet."
  end
end
