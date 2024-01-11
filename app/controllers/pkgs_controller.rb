class PkgsController < ApplicationController
  protect_from_forgery :except => [:api_create, :validate]

  before_action :set_plat, only: [:new,:create]


  def show
    unless signed_in?
      redirect_to new_session_path and return
    end
    @pkg = Pkg.find params[:id]
    history = Pkg.where("id < ?",@pkg.id).limit(20).where(plat_id:@pkg.plat_id).id_desc
    history.each do |e|
      @history ||= {}
      time_str = e.created_at.strftime("%Y-%m-%d")
      @history[time_str] ||= []
      @history[time_str] << e
    end
    unless (browser.platform.ios? && !@pkg.ios?) || (browser.platform.android? && !@pkg.android?)
      @download_url = (browser.platform.android? || browser.platform.ios?) ? @pkg.install_url : @pkg.download_url
    end
  end

  #ios install manifest file
  def manifest
    # rails convert & to \u0026, not %26, so we need to decode it here
    # current_url = URI.decode(request.original_url)
    # parsed_url = URI.parse(current_url)
    # query_obj = CGI::parse(parsed_url.query)
    # token = params[:token] || query_obj['token'].first
    id = params[:id]
    @pkg = Pkg.find id
    # if (@pkg.download_token == token)
    stream = render_to_string(:template=>"pkgs/manifest.xml" )
    render xml: stream
    # else
    #   render status: 403, json: { isSuccess: false, token: token, id: id, url: current_url, error: "Invalid Token"}
    # end
  end

  # validate download token
  def validate
    origin_url = request.headers["X-Original-URI"]
    result = false
    query_params = ''
    if (origin_url)
      current_url = URI.decode(origin_url)
      uri = URI.parse(current_url)
      # then use CGI.parse to parse the query string into a hash of names and values
      query_params = CGI.parse(uri.query)
      @pkg = Pkg.find query_params["id"].first
      if (query_params["token"].first == @pkg.download_token)
        result = true
      end
    end
    if (result)
      render status: 200, json: { isSuccess: true, url: origin_url, id: query_params["id"][0], token: query_params["token"][0]}
    else
      render status: 403, json: { isSuccess: false, url: origin_url, param: query_params}
    end
  end

  def new
    unless signed_in?
      redirect_to new_session_path and return
    end
    @pkg = @plat.pkgs.build
  end

  def create
    authorize!(:create, Pkg)
    pkg = Pkg.new(pkg_params.merge(user_id:current_user.id))
    pkg.app_id = pkg.plat.app_id

    unless pkg_params[:file_nick_name].present?
      pkg.file_nick_name = pkg.display_file_name
    end

    @plat.validate_pkg(pkg)
    
    pkg.save
    redirect_to pkg_path(pkg)
  rescue => e
    redirect_to new_plat_pkg_path(@plat), :flash => { :error => e.message }
  end

  def destroy
    pkg = Pkg.find params[:id]
    authorize!(:destroy, pkg)
    pkg.destroy!
    redirect_to app_plat_path(pkg.app, pkg.plat)
  end


  #api 提交包
  #params
  # - api_token: 授权 token  
  # - plat_id: 要传到的渠道
  # - pkg: 文件
  def api_create
    
    api_token = params[:token]

    user = User.find_by(api_token: api_token)
    unless user
      raise "401 Unauthorized"
    end

    plat = Plat.find params[:plat_id]

    pkg = Pkg.new({file:params[:file], user_id:user.id, plat_id:plat.id, file_nick_name:params[:file_nick_name],features:params[:features]})
    pkg.app_id = pkg.plat.app_id

    unless params[:file_nick_name].present?
      pkg.file_nick_name = pkg.display_file_name
    end

    plat.validate_pkg(pkg)
    
    pkg.save!

    render json: pkg.to_json

  rescue => e
    render json: {error: "#{e.message}"}
  end


  private
  
  def set_plat
    @plat = Plat.find(params[:plat_id])
  end

  # # Never trust parameters from the scary internet, only allow the white list through.
  def pkg_params
    params.require(:pkg).permit(:file,:plat_id,:file_nick_name,:features)
  end
end