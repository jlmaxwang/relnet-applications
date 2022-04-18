# Lists out all the projects that a user
# has access to based on
# * being on the same team
# * being a superuser(removed permission)
# * being in the approved users list for a project and there is a release of author
class ProjectsForUser
  def initialize(user)
    @user = user
  end

  def run
    return [] if @user.deleted
    projects.map do |project|
      next unless user_on_project?(project)
      project
    end.compact.sort_by(&:title)
  end

  private

  def projects
    @user.team.projects.active.includes(:project_users)
  end

  def user_on_project?(project)
    is_released = @user.releases.map(&:project_id).include?(project.id)
    is_user_on_project = project.project_users.map(&:user_id).include? @user.id
    is_released || is_user_on_project
  end
end
