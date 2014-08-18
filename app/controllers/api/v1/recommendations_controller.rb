class Api::V1::RecommendationsController < Api::V1::BaseController

  def index
  end

  def new
  end

  def create
  	# initiate Neography
  	# getting similarity
  	# queryMatch = Neo.execute_query("")

  end

  def show
  	id = params[:id]
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
  	# table = Neo.execute_query("MATCH  (b1:Buyer {userid:'davideko'})-[s:similarity]-(b2:Buyer {userid:'wihihi'}) RETURN s.similarity AS `Cosine Similarity`")
  	# getting neighbors
  	# table = Neo.execute_query("MATCH (b1:Buyer {userid:'davideko'})-[s:similarity]-(b2:Buyer) WITH b2, s.similarity AS sim ORDER BY sim DESC LIMIT 5 RETURN B2.userid AS Neighbor, sim AS Similarity")
  	# generating recommendations
  	recomm = Neo.execute_query("MATCH    (b:Buyer)-[r:rated]->(i:Item), (b)-[s:similarity]-(a:Buyer {userid:'#{id}'})
								 WHERE    NOT((a)-[:rated]->(i))
								 WITH     i, s.similarity AS similarity, r.rating AS rating
								 ORDER BY i.itemid, similarity DESC
								 WITH     i.itemid AS item, COLLECT(rating)[0..3] AS ratings
								 WITH     item, REDUCE(s = 0, i IN ratings | s + i)*1.0 / LENGTH(ratings) AS reco
								 ORDER BY reco DESC
								 RETURN   item AS Item, reco AS Recommendation")
  	render json: {:recommendation => recomm, :message => 'Recommendation generated' }
  end

  def edit
  end

  def update
  end

  def destroy
  end

end

