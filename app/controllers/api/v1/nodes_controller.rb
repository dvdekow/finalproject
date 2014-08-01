class Api::V1::NodesController < Api::V1::BaseController
  def index
  	@neo = Neography::Rest.new
    respond_with(:node => Node.all, :message => 'OK')
  end

  def new
  	@node = Node.new
  end

  def create
    @node = Node.new
    @node.itemname = params[:itemname]
    @node.username = params[:username]
    if @node.save
      render json: {:node => @node, :message => 'Node has been created'}
  	else
      render json: {:message => 'Node has not been created'}
    end
  end

  def show
    @node = Node.find(params[:id])
   	render json: {:node => @node, :message => 'Node found'}
  end

  def edit
    @node = Node.find(params[:id])
  end

  def update
    @node = Node.find(params[:id])
    unless (params[:itemname].nil?) && (params[:username])
      if @node.update_attributes(params[:itemname])
      	@message = 'itemname'
      end
      if @node.update_attributes(params[:username])
      	@message = @message + ' and ' + 'username'
      end
    else
      unless (params[:itemname].nil?)
      	if @node.update_attributes(params[:itemname])
      	  @message = 'itemname'
        end
      end
      unless (params[:username].nil?)
      	if @node.update_attributes(params[:username])
      	  @message = 'username'
        end
      end
    end
    @message = @message + ' updated'
    render json: {:node => @node, :message => @message}
  end
end