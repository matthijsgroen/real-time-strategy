class Script::Generic::Produce < Script::Base
  internal_name :produce

  parameter :factory, :type => :asset, :required => true, :alias => :asset
  parameter :product, :type => :asset_type, :required => true, :alias => :item
  parameter :queue, :type => :array, :element_type => :asset_type, :scope => :private

  def roll
    scenario do |step|
      step.add_to_queue
      step.finish_queue_item
    end
  end

  private

  def add_to_queue
    # 0. use an instance of the product with the faction for determining the prices
    # this way faction's upgrades will be taken into account.
    product_instance = product.new :faction => factory.faction

    # 1. Pay for the product
    # 1a. check for enough resources
    product_instance.build_costs.each do |resource_type, amount|
      raise GameInstance::GameplayError.new(factory, "not enough #{resource_type}", :not_enough_resources) if faction.send(resource_type).amount(execution_time) < amount
    end
    # 1b. payment
    product_instance.build_costs.each do |resource_type, amount|
      faction.send(resource_type).decrease :amount, amount, execution_time
    end

    # 2. Add unit_type to queue
    self.queue << product

    # 3. if not producing...
    if self.end_time.nil?
      # 4. try to pay the operation supply cost of the unit. if successfull ...

      # 5. put factory in production state
      factory.put_in_state :production

      # 6. put end_time to production time
      self.end_time = execution_time + product_instance.build_time
    end
  end

  def finish_queue_item
    #raise self.queue.inspect
    produced     = self.queue.shift
    # 7. create fysical asset
    new_location = factory.exit_point
    new_asset    = produced.new :location => new_location
    factory.faction.assets << new_asset

    # 8. move asset from building exit_point to rally_point

    # 9. construct next item, starting from point 4
    if next_product = queue.first
      product_instance = next_product.new :faction => factory.faction
      self.end_time    = execution_time + product_instance.build_time
      loop_step
    else
      # 10. if queue empty, move building to normal state
      factory.remove_state :production
    end
  end

end
