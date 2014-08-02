class Api::V1::NodesController < Api::V1::BaseController
  def index
  	@neo = Neography::Rest.new
  	getBuyer = @neo.get_nodes_labeled("Buyer")
  	# create new hash
  	allBuyer = Hash.new
  	getBuyer.each_with_index {|value,idx| allBuyer[idx] = value["data"]}
  	# puts allBuyer.to_json
  	# returning all buyer node
    respond_with("buyer" => allBuyer.to_json, :message => 'OK')
  end

  def new
  	@node = Node.new
  end

  def create
  	# initiate neography
  	@neo = Neography::Rest.new
    # @node = Node.new
    # @node.itemname = params[:itemname]
    # @node.username = params[:username]

    # capturing parameter
    userid = 'default'
    itemid = '123'

    type = 'unknown'

    unless params[:itemid].nil?
      itemid = params[:itemid]
    end
    
    unless params[:userid].nil?
  	  userid = params[:userid]
    end

    unless params[:type].nil?
    	type = params[:type]
    end

    nodeBuyer = @neo.create_node("userid" => userid)
    labeledBuyer = @neo.add_label(nodeBuyer, "Buyer")

    nodeItem = @neo.create_node("itemid" => itemid)
    labeledItem = @neo.add_label(nodeItem, "Item")

    # create relationship
    rel = @neo.create_relationship("look", nodeBuyer, nodeItem)

    # return buyer node id, for updating when userid acquired

    # labelnode = @neo.add_label(unlabelnode, "Buyer")
    # newnode = @neo.create_node("userid" => "davideko")
    unless rel.nil?
      render json: {:node => rel, :message => 'Look relation has been created'}
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