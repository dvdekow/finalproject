class Api::V1::RecommendationsController < Api::V1::BaseController
  require 'set'
  def index
	  queryRelation = Neo.execute_query("MATCH (x:Buyer {userid:'david123'} )-[r:rated]->(y:Item) RETURN r,y")
  	
  	render json: {:recommendation => queryRelation}
  end

  def new
  end

  def create

  end
  
  def show
    time = Time.new
    # get id of the buyer
    iduser = params[:id]

    recGrafil = startGrafil(iduser)
    recKnn = knnRec(iduser)

    puts 'RAM USAGE: ' + `pmap #{Process.pid} | tail -1`[10,40].strip
    
    render json: {"grafilrecom" => recGrafil,"knnrecom" => recKnn["data"], :message => 'OK'}
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def knnRec(id)
    # KNN algorhytm with cosine based similarity
    # for get all rating between two buyers
    # table = Neo.execute_query("MATCH (b1:Buyer {userid: 'davideko'})-[r1:look]->(i:Item)<-[r2:look]-(b2:Buyer {userid: 'dewo'}) RETURN i.itemid AS Id, r1.rating AS davideko_rating, r2.rating AS dewo_rating")
    # for calculating similarity and creating relationship
    table = Neo.execute_query("MATCH (b1:Buyer)-[x:rated]->(i:Item)<-[y:rated]-(b2:Buyer)
                                  WITH  SUM(x.rating * y.rating) AS xyDotProduct,
                                   SQRT(REDUCE(xDot = 0.0, a IN COLLECT(x.rating) | xDot + a^2)) AS xLength,
                                   SQRT(REDUCE(yDot = 0.0, b IN COLLECT(y.rating) | yDot + b^2)) AS yLength,
                                   b1, b2
                                 MERGE (b1)-[s:similarity]-(b2)
                                 SET   s.similarity = xyDotProduct / (xLength * yLength)")

    # getting similarity value
    # table = @neo.execute_query("MATCH  (b1:Buyer {userid:'davideko'})-[s:similarity]-(b2:Buyer {userid:'wihihi'}) RETURN s.similarity AS `Cosine Similarity`")
    # getting neighbors
    # table = @neo.execute_query("MATCH (b1:Buyer {userid:'davideko'})-[s:similarity]-(b2:Buyer) WITH b2, s.similarity AS sim ORDER BY sim DESC LIMIT 5 RETURN B2.userid AS Neighbor, sim AS Similarity")
    # generating recommendations
    recomm = Neo.execute_query("MATCH    (b:Buyer)-[r:rated]->(i:Item), (b)-[s:similarity]-(a:Buyer {userid:'#{id}'})
                 WHERE    NOT((a)-[:rated]->(i))
                 WITH     i, s.similarity AS similarity, r.rating AS rating
                 ORDER BY i.itemid, similarity DESC
                 WITH     i.itemid AS item, COLLECT(rating)[0..3] AS ratings
                 WITH     item, REDUCE(s = 0, i IN ratings | s + i)*1.0 / LENGTH(ratings) AS reco
                 ORDER BY reco DESC
                 RETURN   item AS Item, reco AS Recommendation")

    puts 'RAM USAGE: ' + `pmap #{Process.pid} | tail -1`[10,40].strip

    return recomm
  end

  def startGrafil(iduser)
    # array of relationship created, array of relationship = g
    # now create the q, query graph
    puts "in"
    usr = Neo.execute_query("match (buyer:Buyer) where buyer.userid = '#{iduser}' return buyer")
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
    
    most = 0
    most_id = ""
    array_most = Array.new
    itemrec = Array.new

    all_g_relation = Array.new
    getBuyer.each do |value| 
      id_d = value["data"]["userid"]
      unless id_d == iduser
        one = Neo.execute_query("match (buyer:Buyer) where buyer.userid = '#{id_d}' return buyer")
        r = Neo.get_node_relationships(one["data"], "out", "rated")
        puts r
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
        check = Array.new
      end

      #get recommendation
      itemrec = getGrafil(array_most,iduser)
    end

    return itemrec
  end

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
    item = Neo.execute_query("match (buyer:Buyer) where buyer.userid = '#{id}' return buyer")
    user_item = Neo.get_node_relationships(item["data"], "out", "rated")

    user_item.each do |u|
      item_array << u["end"]
    end

    return item_array
  end

  def getGrafil(matchres, usrid)
    result_array = Array.new
    match_a = getItem(usrid)
      
      #iteration start for selected userid
      i = 0
      # get top 5
      while i < 10  && i < matchres.size() do
        match_m = getItem(matchres[i])
        # search unvisited node
        result = match_m - match_a
        
        result.each do |rsl|
          unless result_array.include? rsl.split("/").last
            result_array << rsl.split("/").last
          end
        end
        i += 1
      end
    return result_array
  end

end

