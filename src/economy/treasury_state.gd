class_name TreasuryState
extends RefCounted


var balance: int = 0


func _init(starting_balance: int = 0) -> void:
	balance = starting_balance


func can_afford(amount: int) -> bool:
	return amount >= 0 and amount <= balance


## Adds amount to balance. Rejects negative amounts. Returns true on success.
func add(amount: int) -> bool:
	if amount < 0:
		return false
	balance += amount
	return true


## Spends amount from balance. Rejects negative amounts and overdraft. Returns true on success.
func spend(amount: int) -> bool:
	if amount < 0:
		return false
	if amount > balance:
		return false
	balance -= amount
	return true


func validate() -> Array[String]:
	var errors: Array[String] = []
	if balance < 0:
		errors.append("balance cannot be negative: %d" % balance)
	return errors
