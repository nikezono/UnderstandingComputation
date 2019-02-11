class Value < Struct.new(:value)
  def reducible?
    return false
  end

  def to_s
    return value.to_s
  end

  def inspect
    "<<#{self}>>"
  end
end

class Variable < Struct.new(:name)
  def reducible?
    return true
  end

  def reduce
    return $environment[name]
  end

  def to_s
    return name.to_s
  end

  def inspect
    "<<#{self}>>"
  end

end

class Operator < Struct.new(:left, :right, :operator) 
  def reducible?
    return true
  end

  def inspect
    "<<#{self}>>"
  end

  def reduce
    if left.reducible?
      return Operator.new(left.reduce, right, operator)
    end
    if right.reducible?
      return Operator.new(left, right.reduce, operator)
    end
    return Value.new(eval("#{left.value} #{operator} #{right.value}"))
  end

  def to_s
    "#{left} #{operator} #{right}"
  end

end

class Machine < Struct.new(:expression)
  def step
    self.expression = expression.reduce
  end

  def run
    while expression.reducible?
      puts expression
      step
    end
    puts expression
    puts "\n"
  end
end

if __FILE__ == $0


  $environment = { x: Value.new(1), y: Value.new(2), z: Value.new(3)}
  puts "\e[3m\e[1m 0. $environmentS \e[0m"
  puts $environment, "\n"

  puts "\e[3m\e[1m 1. instantiate \e[0m"
  Machine.new(
    Value.new(2)
  ).run

  puts "\e[3m\e[1m 2. 2 plus 5 \e[0m"
  Machine.new(
    Operator.new(
      Value.new(2),
      Value.new(5),
      "+"
    )
  ).run

  puts "\e[3m\e[1m 3. 2 plus (3 mul 5) \e[0m"
  Machine.new(
    Operator.new(
      Value.new(2),
      Operator.new(
        Value.new(3),
        Value.new(5),
        "*"
      ),
      "+"
    )
  ).run

  puts "\e[3m\e[1m 4. Variable: x plus (y mul 5) \e[0m"
  Machine.new(
    Operator.new(
      Variable.new(:x),
      Operator.new(
        Variable.new(:y),
        Value.new(5),
        "*"
      ),
      "+"
    )
  ).run



end

