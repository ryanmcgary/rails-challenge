require 'open-uri'

class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  def index
    @members = Member.all
  end

  def show
  end

  def new
    @member = Member.new
  end

  def edit
  end

  def header_search
    # TODO: Dump sql var into model
    # TODO: Replace all the ruby with more SQL
    params[:q].gsub!(/\W/, "&")
    @headers = Member.where("to_tsvector('english', headers) @@ to_tsquery('#{params[:q]}:*')")
    # Return all ID's from text search as comma seperated numbers to be used for custom SQL
    matched_ids = @headers.map{|e|e.id}.join(",")    
    member_id = params[:id]

    sql = "
      WITH RECURSIVE iterations(depth, id, root_parent, path, target) AS (
          SELECT 1, id, friender_id, concat(friender_id, ',', friendee_id), friendee_id
          ,array[id] as all_parent_ids
           FROM friendships WHERE friender_id = #{member_id}
      UNION ALL
          SELECT n.depth + 1, t.id, t.friender_id, concat(path, ',', friendee_id), t.friendee_id, all_parent_ids||t.id FROM friendships t
          JOIN iterations n ON n.target = t.friender_id
          AND t.id <> ALL (all_parent_ids)
          where n.depth < 6   -- this is the trick to exclude the endless loops
      )
      SELECT DISTINCT ON (target) target, path, depth FROM iterations where target in (#{matched_ids}) order by target, depth;
    "
    result = ApplicationRecord.connection.exec_query(sql)
    
    # Process SQL paths column string into Array of Integers
    paths = result.rows.map{|e| e[1].split(",").map(&:to_i) }

    # Get names of all users in paths, reduce query to hash of record "`id`: `name`"
    members_pathed = Member.find(paths.flatten).reduce({}){|h,e| h[e.id] = e.name;h}
    
    # map paths and members_pathed so we have an hash with key: parentID and values are array of member names
    @paths = paths.reduce({}){|h,e| h[e.last] = e.map{|d| members_pathed[d]};h}

    # remove headers that do not match query string
    @headers.each{|e| e.headers.reject!{|el| !/#{Regexp.quote(params[:q])}/.match(el)}}
    
    # AR object to hash to add "paths" key:values to records before we serialize as json
    @headers = @headers.to_a.map(&:serializable_hash)
    
    # Add paths data
    @headers.each{|e| e["paths"] = @paths[e["id"]].join(" -> ")}

    respond_to do |format|
      format.json
    end
    
  end

  def create
    @member = Member.new(member_params)
    shrink_url
    scrape_url

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    shrink_url
    scrape_url

    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(
        :name,
        :url,
        :short_url,
        :headers,
        :header_query,
        friend_ids: [])
    end

    def shrink_url
      # TODO: put in background job
      @member.short_url = LinkShrink.shrink_url(@member.url)
    end
    
    def scrape_url
      # TODO: put in background job
      doc = Nokogiri::HTML(open(@member.url))
      @member.headers = doc.css('h1','h2','h3','h4','h5','h6').map{|header| header.text}
    end
end
