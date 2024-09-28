--!strict
local Class = {}

function Class.fromExisting<T, U>(baseClassVft: T, inheritor: U): T & U
	return (setmetatable(inheritor :: any, { __index = baseClassVft }) :: any) :: T & U
end

return Class
