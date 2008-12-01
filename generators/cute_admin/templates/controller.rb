class <%= controller_class_name %>Controller < ApplicationController
  layout "cute_admin"
  before_filter :init_params, :only => :index

  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  def index
    @search = <%= class_name %>.new_search(params[:search])
    @<%= table_name %>, @<%= table_name %>_count = @search.all, @search.count

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %> }
<% if options[:use_ajax] -%>      format.js   {
        render(:update) do |page|
          page.replace_html "admin-ajax-container", :partial => "<%= table_name %>"
        end
      }<% end -%>
    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    @<%= file_name %> = <%= class_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = I18n.t(:created_success, :default => '{{model}} was successfully created.', :model => <%= class_name %>.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = I18n.t(:updated_success, :default => '{{model}} was successfully updated.', :model => <%= class_name %>.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(@<%= file_name %>) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    @<%= file_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= table_name %>_url) }
      format.xml  { head :ok }
    end
  end

  private

  def init_params
    params[:search] ||= {}
  end
end
