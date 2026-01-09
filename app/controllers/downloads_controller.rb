class DownloadsController < ApplicationController
  before_action :authenticate_user!

  def show
    @product = Product.find(params[:id])
    authorize @product, policy_class: DownloadPolicy

    if @product.digital_file.attached?
      redirect_to rails_blob_path(@product.digital_file, disposition: "attachment"), allow_other_host: true
    else
      redirect_to root_path, alert: "File not found."
    end
  end
end
