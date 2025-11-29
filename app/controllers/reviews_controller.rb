class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show update destroy ]

  # GET /reviews
  def index
    render json: Review.all
  end

  # GET /reviews/1
  def show
    render json: @review, status: :ok
  end

  # POST /reviews
  def create
    @review = Review.new(review_params)

    if @review.save
      render json: @review, status: :created
    else
      render json: @review.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /reviews/1
  def update
    if @review.update(review_params)
      render json: @review
    else
      render json: @review.errors, status: :unprocessable_content
    end
  end

  # DELETE /reviews/1
  def destroy
    if @review.destroy
      head :no_content
    else
      render json: @review.errors, status: :unprocessable_content
    end
  end

  private

  def set_review
    @review = Review.find(params.expect(:id))
  end

  def review_params
    params.expect(review: [ :user_id, :book_id, :rating, :body ])
  end
end
