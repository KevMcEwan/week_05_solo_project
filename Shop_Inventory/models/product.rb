require_relative('../db/sql_runner')

class Product

  attr_reader :id

  attr_accessor :name, :description, :quantity, :customer_price, :product_type, :desired_quantity

  def initialize( options )
    @id = options['id'].to_i
    @name = options['name']
    @description = options['description']
    @quantity = options['quantity'].to_f
    @customer_price = options['customer_price'].to_f
    @product_type = options['product_type']
    @desired_quantity = options['desired_quantity'].to_f
  end


  def save()
    sql = "INSERT INTO products
    (name, description, quantity, customer_price, product_type, desired_quantity)
    VALUES
    ($1, $2, $3, $4, $5, $6)
    RETURNING id"
    values = [@name, @description, @quantity, @customer_price, @product_type, @desired_quantity]
    results = SqlRunner.run(sql, values)
    @id = results.first['id'].to_i
  end

  def self.delete_all()
    sql = "DELETE FROM products"
    SqlRunner.run(sql)
  end

  def self.all
    sql = "SELECT * FROM products ORDER BY quantity DESC"
    results = SqlRunner.run( sql )
    return results.map { |product| Product.new( product ) }
  end

  def delete()
    sql = "DELETE FROM products WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def self.find( id )
    sql = "SELECT * FROM products
    WHERE id = $1"
    values = [id]
    product = SqlRunner.run( sql, values )
    result = Product.new( product.first )
    return result
  end

  def update
    sql = "UPDATE products SET (name, description, quantity, customer_price, product_type, desired_quantity) =
    ($1, $2, $3, $4, $5, $6)
    WHERE id = $7"
    values = [@name, @description, @quantity, @customer_price, @product_type, @desired_quantity, @id]
    SqlRunner.run(sql, values)
  end

  def self.stock_order
    sql = "SELECT * FROM products WHERE (quantity/desired_quantity) < 0.2"
    results = SqlRunner.run(sql)
    return results.map { |product| Product.new(product)}
  end

  def stocked_by_wholesaler
    sql = "SELECT wholesalers.wholesaler_name
    FROM wholesalers
    INNER JOIN stock_supply
    ON stock_supply.wholesaler_id = wholesalers.id
    WHERE stock_supply.product_id = $1"
    values = [@id]
    result = SqlRunner.run(sql, values)
    return result.map { |wholesaler| Wholesaler.new(wholesaler).wholesaler_name }
  end

  def supply_price
    sql = "SELECT stock_supply.supply_price
    FROM stock_supply WHERE product_id = $1"
    values = [@id]
    result = SqlRunner.run(sql, values)
    return result.map { |price| Stock_supply.new(price).supply_price}
  end

  def stock_supply
    sql = "SELECT stock_supply.* FROM stock_supply WHERE product_id = $1"
    values = [@id]
    result = SqlRunner.run(sql, values)
    return result.map { |stock_supply| Stock_supply.new(stock_supply)}
  end


  def self.product_type_filter(product_type)
    sql = "SELECT * FROM products
    WHERE product_type = $1"
    values = [product_type]
    results = SqlRunner.run( sql, values )
    return results.map { |product| Product.new(product)}
  end

  def self.sort_by_quantity
    sql = "SELECT * FROM products
    ORDER BY quantity DESC"
    results = SqlRunner.run(sql)
    return results.map { |product| Product.new(product) }
  end





end
