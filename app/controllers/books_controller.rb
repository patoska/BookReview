class BooksController < ApplicationController
  before_action :set_book, only: %i[ show update destroy ]

  # GET /books
  def index
    render json: Book.all
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
    @book = Book.find(params.expect(:id))
  end

  def book_params
    params.expect(book: [ :title ])
  end
end
