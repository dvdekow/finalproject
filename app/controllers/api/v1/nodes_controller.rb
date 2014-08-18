class Api::V1::NodesController < Api::V1::BaseController
  def index
    getBuyer = Neo.get_nodes_labeled("Buyer")
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

    if params[:itemid].nil?
      if params[:userid].nil?
        render json: {:message => 'Node has not been created, please insert parameter'}
      else
        nodeBuyer = Neo.create_node("userid" => params[:userid])
        labeledBuyer = Neo.add_label(nodeBuyer, "Buyer")
        render json: {:userid => params[:userid], :node => nodeBuyer["data"] ,:message => 'Buyer node has been created'}
      end
    else
      nodeItem = Neo.create_node("itemid" => params[:itemid])
      labeledItem = Neo.add_label(nodeItem, "Item")
      render json: {:itemid => params[:itemid], :node => nodeItem["data"], :message => 'Item node has been created'}
    end
  end

  def show
    # this method will return node with id as userid or itemid properties
    id = params[:id]
    # initiate neography
    # checking node in user node and item node
    uquerynode = Neo.execute_query("match (n) where n.userid = '#{id}' return n")
    iquerynode = Neo.execute_query("match (n) where n.itemid = '#{id}' return n")

    # nodeBuyer = Neo.create_node("userid" => "wihihi")
    # labeledBuyer = Neo.add_label(nodeBuyer, "Buyer")
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
    idatrributes = params[:id]
    changeattributes = params[:change]
    value = params[:value]

    # searching node
    que = Neo.execute_query("match (n) where n.userid = '#{idatrributes}' return n")

    unless que["data"].empty?
    quenode = que["data"]
    newnode =  Neo.set_node_properties(quenode, {changeattributes => value})

    render json: {:node => newnode, :message => 'Node attributes updated'}
  else
    render json: {:message => 'node not found'}
  end
  end

  def destroy
    #initialization
    #capturing parameter
    idattributes = params[:id]
    queribuyer = Neo.execute_query("match (n) where n.userid = '#{idattributes}' return n")

    if queribuyer["data"].empty?
      queriitem = Neo.execute_query("match (n) where n.itemid = '#{idattributes}' return n")
      if queriitem["data"].empty?
        render json: {:node => queriitem["data"], :message => 'Node not found'}
      else
        Neo.delete_node(queriitem["data"])
        render json: {:node => queriitem["data"], :message => 'Node succesfully deleted'}
      end
    else
      Neo.delete_node(queribuyer["data"])
      render json: {:node => queribuyer["data"], :message => 'Node succesfully deleted'}
    end
  end
end
