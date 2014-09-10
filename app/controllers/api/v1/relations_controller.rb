class Api::V1::RelationsController < Api::V1::BaseController
  def index
    # initialize neograohy
    queryRelation = Neo.execute_query("match (a)-[r]-(b) return a,b")

    respond_with("relation" => queryRelation, :message => 'OK')
  end

  def new
  end

  def create
    # initiate neography
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

      queryBuyer = Neo.execute_query("match (n) where n.userid = '#{userid}' return n")

      if queryBuyer["data"].empty?
        nodeBuyer = Neo.create_node("userid" => userid)
        labeledBuyer = Neo.add_label(nodeBuyer, "Buyer")
      else
        nodeBuyer = queryBuyer["data"]
      end

      queryItem = Neo.execute_query("match (n) where n.itemid = '#{itemid}' return n")

      if queryItem["data"].empty?
        nodeItem = Neo.create_node("itemid" => itemid)
        labeledItem = Neo.add_label(nodeItem, "Item")
      else
        nodeItem = queryItem["data"]
      end

      # create relationship
      rel = Neo.create_relationship("rated", nodeBuyer, nodeItem)
      # return buyer node id, for updating when userid acquired

      # labelnode = Neo.add_label(unlabelnode, "Buyer")
      # newnode = Neo.create_node("userid" => "davideko")
      unless rel.nil?
        if type.eql? "look"
          wrel = Neo.set_relationship_properties(rel, {"rating" => 1, "type" => type})
          render json: {:node => wrel, :message => 'look relation has been created'}
        else
          wrel = Neo.set_relationship_properties(rel, {"rating" => 2, "type" => type})
          render json: {:node => wrel, :message => 'purchase relation has been created'}
        end
      else
        render json: {:message => 'Node has not been created'}
      end
  end


  def show
    userid = params[:id]
    queryRelation = Neo.execute_query("match (n) where n.userid = '#{userid}' return n")
    #get all relationship
    result = Neo.get_node_relationships(queryRelation["data"]);

    render json: {:relationship =>result, :message => 'OK'}
  end

  def edit
  end

  def update
    userid = params[:id]
    # get the node
    queryNode = Neo.execute_query("match (n) where n.userid = '#{userid}' return n")
    # get the relationship
    relation = Neo.get_node_relationships(queryNode["data"]);

    arrRel = Array.new

    # update attribut
    relation.each do |r|
      if r["type"].eql? "look"
        arrRel << Neo.set_relationship_properties(r, {"rating" => 1})
        arrRel << Neo.set_relationship_properties(r, {"created_at" => time.inspect})
		arrRel << Neo.set_relationship_properties(r, {"updated_at" => time.inspect})
      else
        arrRel << Neo.set_relationship_properties(r, {"rating" => 2})
      end
    end

    render json: {:relationship => arrRel, :message => 'OK' }

  end

  def destroy
  end
end
