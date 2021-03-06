defmodule Private do
  @moduledoc File.read!("README.md")

  defmacro __using__(_opts)  do
    quote do
      require Private
      import  Private, only: [ private: 1, private: 2 ]
    end
  end

  
  @doc """
      private do
        def ...
        defp ...
      end

  All functions in the block will be defined as public if Mix.env is `:test`, 
  private otherwise.  `def` and `defp` are effectively the same in the block.
  """

  defmacro private(env, do:  block) do
    quote do
      unquote(do_private(block, env))
    end
  end

  defmacro private(do:  block) do
    quote do
      unquote(do_private(block, Mix.env))
    end
  end

          
  def do_private(block, _env = :test) do
    make_defs_public(block)
  end

  def do_private(block, _env) do
    make_defs_private(block)
  end
  
  
  def make_defs_private(block) do
    Macro.traverse(block, nil, &make_private/2, &identity/2)
  end

  def make_defs_public(block) do
    Macro.traverse(block, nil, &make_public/2, &identity/2)
  end

  def make_private({:def, meta, code}, acc) do
    { {:defp, meta, code}, acc }
  end
  
  def make_private(ast, acc), do: identity(ast, acc)

  def make_public({:defp, meta, code}, acc) do
    { {:def, meta, code}, acc }
  end
  
  def make_public(ast, acc), do: identity(ast, acc)
  
  def identity(ast, acc) do
    { ast, acc }
  end


  def running_in_test() do
    Mix.env == :test
  end
end
