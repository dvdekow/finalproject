class Api::V1::NodesController < Api::V1::BaseController
  require 'set'

  def checkSub(qgraph,feature)
    puts "========================================"
    puts "start checking"
    puts feature.size()
    if feature.size() <= qgraph.size()
      i = 0
      qgraph.each do |qsub|
        feature.each do |f|
          if qsub["end"] == f["end"]
            i = i + 1
            puts ""
            puts "THIS IS QSUB"
            puts qsub["end"]
            puts "THIS IS F"
            puts f["end"]
          end
        end
      end
      if i == feature.size()
        puts "graph match"
        return 1
      else
        puts "graph not match"
        return 0
      end
    else
      return 0
    end
    puts "end checking"
  end

  def getItem(id)
    item_array = Array.new
    item = Neo.execute_query("match (n) where n.userid = '#{id}' return n")
    user_item = Neo.get_node_relationships(item["data"], "out", "rated")

    user_item.each do |u|
      item_array << u["end"]
    end

    return item_array
  end

  def getGrafil(matchres, usrid)
    result_array = Array.new
    if matchres.instance_of? Array
      puts "array"

      match_a = getItem(usrid)
      puts match_a
      puts "end of match a"
      puts ""
      i = 0
      # get top 5
      while i < 10  && i < matchres.size() do
        match_m = getItem(matchres[i])
        puts match_m
        puts ""
        result = match_m - match_a

        result_array << result[0]
        i += 1
      end
      puts result_array
    else
      puts "not array"
    end
  end

  def index
  	# get id of the buyer
  	iduser = "a2"

  	# array of relationship created, array of relationship = g
    # now create the q, query graph
    usr = Neo.execute_query("match (n) where n.userid = '#{iduser}' return n")
    usr_r = Neo.get_node_relationships(usr["data"], "out", "rated")

    # after query graph created extract the features
    # features = Array.new
    maxL = usr_r.size()
    # puts maxL
    yss = 1.upto(maxL).flat_map do |n|
  	  usr_r.combination(n).to_a
	  end

	  check = Array.new

	  # array of relationship created, array of relationship = g

    getBuyer = Neo.get_nodes_labeled("Buyer")

    count_sub = Array.new
    most = 0
    most_id = ""
    array_most = Array.new

    all_g_relation = Array.new
    getBuyer.each do |value| 
      id_d = value["data"]["userid"]
      unless id_d == iduser
        one = Neo.execute_query("match (n) where n.userid = '#{id_d}' return n")
        r = Neo.get_node_relationships(one["data"], "out", "rated")
        all_g_relation << r
        yss.each do |ycomp|
          if ycomp.size() == 1
            check << checkSub(r,ycomp)
          end
	      end
      sum = 0
      check.each do |ea|
        sum = sum + ea
      end
      unless most > sum
        if most == 0
          most = sum
        elsif most < sum
          most_id = id_d
          array_most = Array.new
        end
        array_most << id_d
      end
      count_sub << {:userid => id_d, :sum => sum}
	    # count_sub[counter][id_d] = sum
	    check = Array.new
      end
      #get recommendation
      if array_most.size() > 1
        puts "much same"
        getGrafil(array_most,iduser)
      else
        puts "only one"
        #getGrafil(most_id,iduser)
      end
    end

	puts 'RAM USAGE: ' + `pmap #{Process.pid} | tail -1`[10,40].strip
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
    render json: {"graph" => all_g_relation, "query graph" => usr_r, "features" => yss, "count" => count_sub, "most" => most, "array_most" => array_most,:message => 'OK'}
  end

  def new
    # @node = Node.new
  end

  def create
  	time = Time.new
    # initiate neography
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
