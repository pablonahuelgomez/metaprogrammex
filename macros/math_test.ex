defmodule MathTest do
  use Assertion

  test "integers can be added" do
    assert(1 + 1 < 2 + 1)
  end

  test "the answer to life an everything else" do
    assert 42 == 42
  end

  test "the truth" do
    assert Enum.empty?([])
  end

  test "the truth II" do
    assert true
  end

  test "something false" do
    assert false
  end
end