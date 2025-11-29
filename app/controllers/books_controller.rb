class BooksController < ApplicationController
  before_action :set_book, only: %i[ show update destroy ]

  # GET /books
  def index
    render json: Book.left_joins(reviews: :user)
      .select(
        "books.*,
        CASE
          WHEN SUM(CASE WHEN users.status != 1 THEN 1 ELSE 0 END) < 3
            THEN 'Reseñas Insuficientes'
            ELSE ROUND(AVG(CASE WHEN users.status != 1 THEN reviews.rating ELSE NULL END), 1)
        END
        AS rating"
      )
      .group("books.id")
  end

  # GET /books/1
  def show
    render json: @book, status: :ok
  end

  # POST /books
  def create
    @book = Book.new(book_params)
    if @book.save
      render json: @book, status: :created
    else
      render json: @book.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      render json: @book
    else
      render json: @book.errors, status: :unprocessable_content
    end
  end

  # DELETE /books/1
  def destroy
    if @book.destroy
      head :no_content
    else
      render json: @book.errors, status: :unprocessable_content
    end
  end

  private

  def set_book
    @book = Book.left_joins(reviews: :user)
      .select(
        "books.*,
        CASE
          WHEN SUM(CASE WHEN users.status != 1 THEN 1 ELSE 0 END) < 3
            THEN 'Reseñas Insuficientes'
            ELSE ROUND(AVG(CASE WHEN users.status != 1 THEN reviews.rating ELSE NULL END), 1)
        END
        AS rating"
      )
      .where("books.id = ?", params.expect(:id))
      .group("books.id")
      .first
    head :not_found unless @book
  end

  def book_params
    params.expect(book: [ :title ])
  end
end
