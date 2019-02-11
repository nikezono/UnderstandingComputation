require './2_3_1_1.rb'

module Statement
  class DoNothing
    def to_s
      "do-nothing"
    end
    def inspect
      "<<#{self}>>"
    end
    def == (other_statement)
      other_statement.instance_of?(DoNothing)
    end
    def reducible?
      return false
    end
  end

  class Assign < Struct.new(:name, :expression)
    def to_s
      "#{name} = #{expression}"
    end
    def inspect
      "<<#{self}>>"
    end
    def reducible?
      return true
    end
    def reduce
      if expression.reducible?
        return Assign.new(name, expression.reduce)
      else
        $environment = $environment.merge({name => expression})
        return DoNothing.new
      end
    end
  end

  TRUE = Value.new(true)
  FALSE = Value.new(false)
  class If < Struct.new(:condition, :consequence, :alternative)
    def to_s
      "If (#{condition}) { #{consequence} } else { #{alternative} }"
    end

    def inspect
      "<<#{self}>>"
    end

    def reducible?
      return true
    end

    def reduce
      if condition.reducible?
        return If.new(condition.reduce, consequence, alternative)
      else
        case condition
        when TRUE
          return consequence
        when FALSE
          return alternative
        end
      end
    end
  end

  NOTHING = DoNothing.new
  class Sequence < Struct.new(:first, :second)
    def to_s
      "#{first}; #{second}"
    end

    def inspect
      "<<#{self}>>"
    end

    def reducible?
      return true
    end

    def reduce
      case first
      when NOTHING
        return second
      else
        return Sequence.new(first.reduce, second)
      end
    end
  end

  class While < Struct.new(:condition, :body)
    def to_s
      "while (#{condition}) { #{body} }"
    end

    def inspect
      "<<#{self}"
    end

    def reducible?
      return true
    end

    def reduce
      return If.new(condition, Sequence.new(body, self), NOTHING)
    end
  end
end

Object.send(:remove_const, :Machine)
class Machine < Struct.new(:statement)
  def step
    self.statement = statement.reduce
  end

  def run
    print "ENV: \e[35m", $environment, "\e[0m \n\n"
    while statement.reducible?
      print "\e[3m", statement, "\e[0m \n"
      step
    end
    print "\e[3m", statement, "\e[0m \n\n"
    print "ENV: \e[35m", $environment, "\e[0m \n\n"
  end
end

if __FILE__ == $0


  $environment = { x: Value.new(1), y: Value.new(2), z: Value.new(3)}
  puts "\e[31m\e[3m\e[1m 0. ENVIRONMENTS \e[0m"
  puts $environment, "\n"

  puts "\e[31m\e[3m\e[1m 1. Assign \e[0m"
  Machine.new(
    Statement::Assign.new(
      :x,
      Value.new(50)
    )
  ).run

  puts "\e[31m\e[3m\e[1m 2. If \e[0m"
  Machine.new(
    Statement::If.new(
      Operator.new(
        Value.new(1),
        Value.new(2),
        "=="
      ),
      Statement::Assign.new(
        :x,
        Variable.new(:y)
      ),
      Statement::Assign.new(
        :new,
        Variable.new(:z)
      )
    )
  ).run

  puts "\e[31m\e[3m\e[1m 3. Sequence \e[0m"
  Machine.new(
    Statement::Sequence.new(
      Statement::If.new(
        Operator.new(
          Value.new(1),
          Value.new(2),
          "!="
        ),
        Statement::Assign.new(
          :x,
          Value.new(10)
        ),
        Statement::Assign.new(
          :new,
          Variable.new(:z)
        )
      ),
      Statement::Assign.new(
        :x,
        Value.new(3)
      ),
    )
  ).run

  puts "\e[31m\e[3m\e[1m 4. While \e[0m"
  Machine.new(
    Statement::While.new(
        Operator.new(
          Variable.new(:x),
          Value.new(5),
          "<"
        ),
        Statement::Assign.new(
          :x,
          Operator.new(
            Variable.new(:x),
            Value.new(1),
            "+"
          )
      ),
    )
  ).run

end

