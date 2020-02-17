defmodule ControlFlow do
  
  defmacro myif(expr, do: if_block), do: if(expr, do: if_block, else: nil)
  defmacro myif(expr, do: if_block, else: else_block) do
    quote do
      case unquote(expr) do
        result when result in [false, nil] -> unquote(else_block)
        _ -> unquote(if_block)
      end
    end
  end

end