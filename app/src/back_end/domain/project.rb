class Project

  extend Forwardable

  def self.create(authenticated_account:)
    if !authenticated_account.entitlements.can_add_new_project?
      raise Brut::BackEnd::Errors::Bug, "#{authenticated_account.account.external_id} has reached its plan limit for projects - this should not have been called"
    end
    project = DB::Project.new(account: authenticated_account.account)
    Project.new(project:)
  end

  def self.find!(external_id:,account:)
    project = DB::Project.find!(external_id:, account:)
    self.new(project:)
  end

  def initialize(project:)
    @project = project
  end

  def_delegators :@project, :external_id, :name, :description, :adrs_shared_by_default

  def archived? = !@project.archived_at.nil?

  def save(form:)
    if name_already_in_use?(form.name)
      return name_in_use!(form:)
    end
    @project.update(name: form.name,
                    description:form.description,
                    adrs_shared_by_default:form.adrs_shared_by_default == "true")
    form
  rescue Sequel::UniqueConstraintViolation
    name_in_use!(form:)
  end

private

  def name_in_use!(form:)
    form.server_side_constraint_violation(input_name: :name, key: :taken)
    form
  end

  def name_already_in_use?(proposed_name)
    scope = DB::Project.where(name: proposed_name, account: @project.account)
    if !@project.external_id.nil?
      scope = scope.where(Sequel.lit("external_id <> ?",@project.external_id))
    end
    scope.any?
  end
end
