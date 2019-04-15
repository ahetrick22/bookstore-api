# author has a built in 10% discount for self-published books
# books are dependent on author so that when an author is deleted, all the books also delete

class Author < ApplicationRecord
  def discount() 10 end
    has_many :books, dependent: :destroy
    has_many :published, foreign_key: :publisher_id, class_name: 'Book', as: :publisher
end
