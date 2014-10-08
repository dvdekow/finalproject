class Api::V1::NodesController < Api::V1::BaseController
  def index
    # create new hash
    # allBuyer = Hash.new
    # getBuyer.each_with_index {|value,idx| allBuyer[idx] = Neo.get_node_relationships(value["data"])}
    # puts getBuyer.to_json
    # gr = Neo.get_node_relationships(getBuyer[0]["data"], "out")
    # returning all buyer node
    # queryBuyer = Neo.execute_query("match (n) where n.userid = '#{userid}' return n")
    # ququ = Neo.execute_query("match (n) where n.userid = 'david123' return n")
    # r = Neo.get_node_relationships(ququ["data"], "out", "rated")
    # quqi = Neo.execute_query("match (n) where n.userid = 'eko333' return n")
    # ri = Neo.get_node_relationships(ququ["data"], "out", "rated")
    # all_g_relation = Array.new
    # all_g_relation << r
    # all_g_relation << ri
    # getBuyer.each {|value| all_g_relation << Neo.execute_query("MATCH (x:Buyer {userid:'#{value["data"]["id"]}'} )-[r:rated]->(y:Item) RETURN r")}
    # render json: {"graph" => all_g_relation, "query graph" => usr_r, "features" => yss, "count" => count_sub, "most" => most, "array_most" => array_most,"recom" => itemrec,:message => 'OK'}
  end

  def new
    # @node = Node.new
  end

  def create
    time = Time.new
    
    if params[:itemid].nil?
      if params[:userid].nil?
        render json: {:message => 'Node has not been created, please insert parameter'}
      else
        nodeBuyer = Neo.create_node("userid" => params[:userid])
        labeledBuyer = Neo.add_label(nodeBuyer, "Buyer")
        labeledBuyer =  Neo.set_node_properties(nodeBuyer, { "created_at" => time.inspect })
      labeledBuyer =  Neo.set_node_properties(nodeBuyer, { "updated_at" => time.inspect })
        render json: {:userid => params[:userid], :node => nodeBuyer["data"] ,:message => 'Buyer node has been created'}
      end
    else
      nodeItem = Neo.create_node("itemid" => params[:itemid])
      labeledItem = Nneo.add_label(nodeItem, "Item")
      labeledItem =  Neo.set_node_properties(nodeItem, { "created_at" => time.inspect })
    labeledItem =  Neo.set_node_properties(nodeItem, { "updated_at" => time.inspect })
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
    time = Time.new

    idatrributes = params[:id]
    changeattributes = params[:change]
    value = params[:value]

    # searching node
    que = Neo.execute_query("match (n) where n.userid = '#{idatrributes}' return n")

    unless que.empty?
    # quenode = que["data"]
      newnode =  Neo.set_node_properties(que, {changeattributes => value})
      newnode =  Neo.set_node_properties(que, { "updated_at" => time.inspect })

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