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
    # set default to avoid null params
    userid = 'default'
    itemid = '123'
    type = 'unknown'
    # capturing parameter
    unless params[:itemid].nil?
      itemid = params[:itemid]
    end
    
    unless params[:userid].nil?
  	  userid = params[:userid]
    end

    unless params[:type].nil?
    	type = params[:type]
    end

    queryBuyer = @neo.execute_query("match (n) where n.userid = '#{userid}' return n")

    if queryBuyer["data"].empty?
      nodeBuyer = @neo.create_node("userid" => userid)
      labeledBuyer = @neo.add_label(nodeBuyer, "Buyer")
    else
      nodeBuyer = queryBuyer["data"]
    end

    queryItem = @neo.execute_query("match (n) where n.itemid = '#{itemid}' return n")

    if queryItem["data"].empty?
      nodeItem = @neo.create_node("itemid" => itemid)
      labeledItem = @neo.add_label(nodeItem, "Item")
    else
      nodeItem = queryItem["data"]
    end

    # create relationship
    rel = @neo.create_relationship(type, nodeBuyer, nodeItem)

    # return buyer node id, for updating when userid acquired

    # labelnode = @neo.add_label(unlabelnode, "Buyer")
    # newnode = @neo.create_node("userid" => "davideko")
    unless rel.nil?
      render json: {:node => rel, :message => 'look relation has been created'}
  	else
      render json: {:message => 'Node has not been created'}
    end
  end

  def show
  	# this method will return node with id as userid or itemid properties
    id = params[:id]
    # initiate neography
    @neo = Neography::Rest.new
    # checking node in user node and item node
    uquerynode = @neo.execute_query("match (n) where n.userid = '#{id}' return n")
    iquerynode = @neo.execute_query("match (n) where n.itemid = '#{id}' return n")
  	
  	# nodeBuyer = @neo.create_node("userid" => "wihihi")
    # labeledBuyer = @neo.add_label(nodeBuyer, "Buyer")
    if uquerynode["data"].empty? && iquerynode["data"].empty?
   	   render json: {:message => 'Node not found'}
   	elsif iquerynode["data"].empty?
   	   render json: {:node => uquerynode["data"],:message => 'Node user found'}
   	else 
   	   render json: {:node => iquerynode["data"], :message => 'Node item found'}
   	end
  end

  def edit
    @node = Node.find(params[:id])
  end

  def update
  	@neo = Neography::Rest.new

  	idatrributes = params[:id]
  	changeattributes = params[:change]
  	value = params[:value]

  	# searching node
  	que = @neo.execute_query("match (n) where n.userid = '#{idatrributes}' return n")

  	unless que["data"].empty?
	  quenode = que["data"]
	  newnode =  @neo.set_node_properties(quenode, {changeattributes => value})

	  render json: {:node => newnode, :message => 'Node attributes updated'}
	else
	  render json: {:message => 'node not found'}
	end
    # @node = Node.find(params[:id])
    # unless (params[:itemname].nil?) && (params[:username])
    #  if @node.update_attributes(params[:itemname])
    #  	@message = 'itemname'
    #  end
    #  if @node.update_attributes(params[:username])
    #  	@message = @message + ' and ' + 'username'
    #  end
    #else
    #  unless (params[:itemname].nil?)
    #  	if @node.update_attributes(params[:itemname])
    #  	  @message = 'itemname'
    #    end
    #  end
    #  unless (params[:username].nil?)
    #  	if @node.update_attributes(params[:username])
    #  	  @message = 'username'
    #    end
    #  end
    # end
    # @message = @message + ' updated'
    # render json: {:node => @node, :message => @message}
  end
end