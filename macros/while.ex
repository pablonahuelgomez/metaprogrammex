defmodule Loop do
  defmacro while(condition, do: block) do
    quote do
      try do
        for _ <- Stream.cycle([:ok]) do
          if unquote(condition) do
            unquote(block)
          else
            Loop.break
          end
        end
      catch
        :break -> :ok
      end
    end
  end

  def break do
    throw :break
  end
end

defmodule Test do
  import Loop

  def exec do
    pid = spawn(fn -> :timer.sleep(4000) end)
    while Process.alive?(pid) do
      IO.puts "Process #{inspect pid} is alive!"
      :timer.sleep 1000
    end
  end
end