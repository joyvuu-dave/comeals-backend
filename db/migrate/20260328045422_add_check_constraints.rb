class AddCheckConstraints < ActiveRecord::Migration[7.0]
  def up
    # Remediate any data that would violate the new constraints.
    # These fixes are logged so the admin knows exactly what changed.
    #
    # Rationale for each remediation:
    #
    # Negative multiplier → 0: "attended but pays nothing" is the closest valid
    # state. Negative multiplier would produce negative costs (person gets paid
    # to eat), which is unambiguously corrupt. For reconciled meals, settlements
    # are already persisted in reconciliation_balances and won't be affected.
    #
    # Zero/negative cap → NULL: removes the cap (uncapped). A cap of 0 makes
    # every meal free; negative is nonsensical. NULL means "no cap," which is
    # the safest default. The admin can re-set a positive cap afterward.
    # For unreconciled meals, the next billing:recalculate run will correct
    # any affected balances.

    fix_count = Guest.where("multiplier < 0").update_all(multiplier: 0)
    say "Fixed #{fix_count} guests with negative multiplier → 0" if fix_count > 0

    fix_count = MealResident.where("multiplier < 0").update_all(multiplier: 0)
    say "Fixed #{fix_count} meal_residents with negative multiplier → 0" if fix_count > 0

    fix_count = Resident.where("multiplier < 0").update_all(multiplier: 0)
    say "Fixed #{fix_count} residents with negative multiplier → 0" if fix_count > 0

    fix_count = Meal.where("cap IS NOT NULL AND cap <= 0").update_all(cap: nil)
    say "Fixed #{fix_count} meals with zero/negative cap → NULL (uncapped)" if fix_count > 0

    fix_count = Community.where("cap IS NOT NULL AND cap <= 0").update_all(cap: nil)
    say "Fixed #{fix_count} communities with zero/negative cap → NULL (uncapped)" if fix_count > 0

    add_check_constraint :guests, "multiplier >= 0", name: "guests_multiplier_non_negative"
    add_check_constraint :meal_residents, "multiplier >= 0", name: "meal_residents_multiplier_non_negative"
    add_check_constraint :residents, "multiplier >= 0", name: "residents_multiplier_non_negative"
    add_check_constraint :meals, "cap IS NULL OR cap > 0", name: "meals_cap_positive_or_null"
    add_check_constraint :communities, "cap IS NULL OR cap > 0", name: "communities_cap_positive_or_null"
  end

  def down
    remove_check_constraint :guests, name: "guests_multiplier_non_negative"
    remove_check_constraint :meal_residents, name: "meal_residents_multiplier_non_negative"
    remove_check_constraint :residents, name: "residents_multiplier_non_negative"
    remove_check_constraint :meals, name: "meals_cap_positive_or_null"
    remove_check_constraint :communities, name: "communities_cap_positive_or_null"
  end
end
