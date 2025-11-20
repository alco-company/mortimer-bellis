class TenantBackupsController < ApplicationController
  before_action :authenticate_user!

  def download
    filename = params[:filename]
    
    # Security: validate filename format (tenant_ID_TIMESTAMP.tar.gz)
    unless filename.match?(/\Atenant_\d+_\d{14}\.tar\.gz\z/)
      return head :not_found
    end
    
    file_path = Rails.root.join("storage", "tenant_backup", filename)
    
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
end
