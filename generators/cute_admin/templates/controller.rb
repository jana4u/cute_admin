class <%= controller_class_name %>Controller < ApplicationController
  layout "cute_admin"

  # GET <%= url_namespace %>/<%= plural_name %>
  # GET <%= url_namespace %>/<%= plural_name %>.xml
  def index
    @search = <%= model_name %>.search(params[:search])
    if params[:per_page] && params[:per_page].blank?
      @<%= plural_name %> = @search.distinct_all
    else
      @<%= plural_name %> = @search.distinct_paginate(:page => params[:page], :per_page => params[:per_page])
    end
    @<%= plural_name %>_count = @search.distinct_count

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

  # GET <%= url_namespace %>/<%= plural_name %>/1
  # GET <%= url_namespace %>/<%= plural_name %>/1.xml
  def show
    @<%= singular_name %> = <%= model_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end

  # GET <%= url_namespace %>/<%= plural_name %>/new
  # GET <%= url_namespace %>/<%= plural_name %>/new.xml
  def new
    @<%= singular_name %> = <%= model_name %>.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= singular_name %> }
    end
  end

  # GET <%= url_namespace %>/<%= plural_name %>/1/edit
  def edit
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
  end

  # POST <%= url_namespace %>/<%= plural_name %>
  # POST <%= url_namespace %>/<%= plural_name %>.xml
  def create
    @<%= singular_name %> = <%= model_name %>.new(params[:<%= singular_name %>])

    respond_to do |format|
      if @<%= singular_name %>.save
        flash[:notice] = I18n.t(:created_success, :default => '{{model}} was successfully created.', :model => <%= model_name %>.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(<%= singular_route_url %>(@<%= singular_name %>)) }
        format.xml  { render :xml => @<%= singular_name %>, :status => :created, :location => <%= singular_route_url %>(@<%= singular_name %>) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT <%= url_namespace %>/<%= plural_name %>/1
  # PUT <%= url_namespace %>/<%= plural_name %>/1.xml
  def update
    @<%= singular_name %> = <%= model_name %>.find(params[:id])

    respond_to do |format|
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = I18n.t(:updated_success, :default => '{{model}} was successfully updated.', :model => <%= model_name %>.human_name, :scope => [:railties, :scaffold])
        format.html { redirect_to(<%= singular_route_url %>(@<%= singular_name %>)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE <%= url_namespace %>/<%= plural_name %>/1
  # DELETE <%= url_namespace %>/<%= plural_name %>/1.xml
  def destroy
    @<%= singular_name %> = <%= model_name %>.find(params[:id])
    @<%= singular_name %>.destroy

    respond_to do |format|
      format.html { redirect_to(<%= plural_route_url %>) }
      format.xml  { head :ok }
    end
  end
end
