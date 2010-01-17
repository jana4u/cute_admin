class <%= controller_class_name %>Controller < ApplicationController
  layout "cute_admin"

  # GET /<%= plural_name %>
  # GET /<%= plural_name %>.xml
  def index
    @search = <%= model_name %>.new_search(params[:search])
    @<%= plural_name %>, @<%= plural_name %>_count = @search.all, @search.count

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= plural_name %> }
<% if options[:use_ajax] -%>      format.js   {
        render(:update) do |page|
          page.replace_html "admin-ajax-container", :partial => "table"
        end
      }<% end -%>
    end
  end

  # GET /<%= plural_name %>/1
  # GET /<%= plural_name %>/1.xml
  def show
    @<%= singular_name %> = <%= model_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end

  # GET /<%= plural_name %>/new
  # GET /<%= plural_name %>/new.xml
  def new
    @<%= singular_name %> = <%= model_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end

  # GET /<%= plural_name %>/1/edit
  def edit
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
  end

  # POST /<%= plural_name %>
  # POST /<%= plural_name %>.xml
  def create
    @<%= singular_name %> = <%= model_name %>.new(params[:<%= singular_name %>])

    respond_to do |format|
      if @<%= singular_name %>.save
        flash[:notice] = I18n.t(:created_success, :default => '{{model}} was successfully created.', :model => <%= model_name %>.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(<% if nested_routes? %><%= singular_route %>(@<%= singular_name %>)<% else %>@<%= singular_name %><% end %>) }
        format.xml  { render :xml => @<%= singular_name %>, :status => :created, :location => <% if nested_routes? %><%= singular_route %>(@<%= singular_name %>)<% else %>@<%= singular_name %><% end %> }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= plural_name %>/1
  # PUT /<%= plural_name %>/1.xml
  def update
    @<%= singular_name %> = <%= model_name %>.find(params[:id])

    respond_to do |format|
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = I18n.t(:updated_success, :default => '{{model}} was successfully updated.', :model => <%= model_name %>.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(<% if nested_routes? %><%= singular_route %>(@<%= singular_name %>)<% else %>@<%= singular_name %><% end %>) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= plural_name %>/1
  # DELETE /<%= plural_name %>/1.xml
  def destroy
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
    @<%= singular_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= plural_route %>) }
      format.xml  { head :ok }
    end
  end
end
