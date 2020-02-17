defmodule Assertion do
  defmacro assert({operator, _, [lhs, rhs]}) do    
    quote bind_quoted: [o: operator, x: lhs, y: rhs] do
      fn -> Assertion.Test.assert(o, x, y) end
    end
  end
  defmacro assert(expression) do
    quote bind_quoted: [e: expression] do
      fn -> Assertion.Test.assert(e) end
    end
  end

  defmacro refute(expression) do
    quote bind_quoted: [e: expression] do
      fn -> Assertion.Test.refute(e) end
    end
  end

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run do
        Assertion.Test.run(@tests, __MODULE__)
      end
    end
  end

  defmacro test(description, do: test_block) do
    test_func = description |> Macro.underscore |> String.to_atom

    quote do
      Module.register_attribute __MODULE__, :"assertions_#{unquote(test_func)}", accumulate: true
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    Enum.each tests, fn tuple ->
      Kernel.spawn async_run(module, tuple)
    end
  end

  defp async_run(module, {test_func, description}) do
    fn () ->
      assert = apply(module, test_func, [])
      case assert.() do
        :ok             -> IO.write "."
        {:fail, reason} -> IO.puts """
        ==================================================
        Failure: #{String.capitalize description}
        ==================================================
        #{reason}
        """
      end
    end
  end

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end
  def assert(:==, lhs, rhs) do
    {:fail, """
      Expected:       #{lhs}
      To be equal to: #{rhs}
      """}
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end
  def assert(:>, lhs, rhs) do
    {:fail, """
      Expected:           #{lhs}
      To be greater than: #{rhs}
      """} 
  end

  def assert(:<, lhs, rhs) when lhs < rhs do
    :ok
  end
  def assert(:<, lhs, rhs) do
    {:fail, """
      Expected:         #{lhs}
      To be less than:  #{rhs}
      """}
  end

  def assert(true) do
    :ok
  end
  def assert(false) do
    {:fail, """
      Expected: false
      To be true
      """}
  end

  def refute(false) do
    :ok
  end
  def refute(true) do
    {:fail, """
      Expected: true
      To be false
      """}
  end
end