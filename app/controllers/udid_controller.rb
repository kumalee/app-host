require_relative '../../lib/parsers/pkg_adapter'

class UdidController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create]
  
  def create
    profile_service_attributes = PkgAdapter::ConfigParser.mobileconfig(request.raw_post)
    udid = profile_service_attributes.value['UDID'].value
    redirect_to "#{request.base_url}udid?udid=#{udid}", :status => 301
  end

  def index
    unless signed_in?
      redirect_to new_session_path and return
    end
    @udid = params[:udid]
  end

  def mobileconfig
    unless signed_in?
      redirect_to new_session_path and return
    end
    path = Rails.root.join("public/ota_helper.mobileconfig")
    mobileconfig = File.read(path)
    mobileconfig.gsub! '__URL__', "#{request.base_url}/udid"
    send_data mobileconfig, :filename => "ota_helper.mobileconfig"
  end


end