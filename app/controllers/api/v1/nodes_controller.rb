class Api::V1::NodesController < Api::V1::BaseController
  def index
  	@neo = Neography::Rest.new
  	getBuyer = @neo.get_nodes_labeled("Buyer")
  	# create new hash
  	allBuyer = Hash.new
  	getBuyer.each_with_index {|value,idx| allBuyer[idx] = value["data"]}
  	# puts allBuyer.to_json
  	# returning all buyer node
    render json: {"buyer" => allBuyer.to_json, :message => 'OK'}
  end

  def new
  	# @node = Node.new
  end

  def create
  	# initiate neography
  	@neo = Neography::Rest.new

    if params[:itemid].nil?
      if params[:userid].nil?
        render json: {:message => 'Node has not been created, please insert parameter'}
      else
      	nodeBuyer = @neo.create_node("userid" => userid)
        labeledBuyer = @neo.add_label(nodeBuyer, "Buyer")
        render json: {:message => 'Buyer node has been created'}
      end
    else
      nodeItem = @neo.create_node("itemid" => itemid)
      labeledItem = @neo.add_label(nodeItem, "Item")
      render json: {:message => 'Item node has been created'}
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
    # @node = Node.find(params[:id])
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
  end

  def destroy
    #initialization
    @neo = Neography::Rest.new

    #capturing parameter
    idattributes = params[:id]
    queribuyer = @neo.execute_query("match (n) where n.userid = '#{idattributes}' return n")

    if queribuyer["data"].empty?
      queriitem = @neo.execute_query("match (n) where n.itemid = '#{idattributes}' return n")
      if queriitem["data"].empty?
      	render json: {:node => queriitem["data"], :message => 'Node not found'}
      else
      	@neo.delete_node(queriitem["data"])
      	render json: {:node => queriitem["data"], :message => 'Node succesfully deleted'}
      end
    else
    	@neo.delete_node(queribuyer["data"])
    	render json: {:node => queribuyer["data"], :message => 'Node succesfully deleted'}
    end
  end
end