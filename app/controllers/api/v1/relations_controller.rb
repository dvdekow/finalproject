class Api::V1::RelationsController < Api::V1::BaseController
	def index
	  # initialize neograohy
      @neo = Neography::Rest.new
      queryRelation = @neo,execute_query("match (a)-[r]-(b) return a,b")

      respond_with("relation" => queryRelation, :message => 'OK')
	end

	def new
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

	def edit
	end

	def update
	end

	def destroy
	end
end