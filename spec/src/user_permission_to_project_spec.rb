require "rails_helper"

RSpec.describe UserPermissionToProject do
  subject       { described_class.new(project, user) }
  let(:project) { create(:project, :with_team) }

  context "when the user is on the same team" do
    let(:user) { create(:user, team: project.team) }

    context "when the user is deleted" do
      before do
        user.update(deleted: true)
      end

      it "returns false" do
        expect(subject.run).to eq(false)
      end
    end

    context "when the project has a specific user list" do
      before do
        create(:project_user, project: project, user: create(:user, team: project.team))
      end

      context "and the user is on that list" do
        before do
          create(:project_user, project: project, user: user)
        end

        it "returns true" do
          expect(subject.run).to eq(true)
        end
      end

      context "and the user is NOT on that list" do
        # unnecessary clause
        # context "and the user is not a super user" do
        it "returns false" do
          expect(subject.run).to eq(false)
          # end
        end

        context "even if the user is a super user" do
          before do
            user.update(super_user: true)
          end

          # it "returns true" do
          #   expect(subject.run).to eq(true)
          # end

          # remove persmisson of user when not on list but a super user
          it 'returns false' do
            expect(subject.run).to eq(false)
          end
        end
      end
    end

    context "when the project DOES NOT have a specific user list" do
      # it "returns true" do
      #   expect(subject.run).to eq(true)
      # end
      context 'this user created a release' do
        before do
          create(:release, project: project, user: user)
        end
        it 'returns true' do
          expect(subject.run).to eq(true)
        end
      end
      context 'this user DID NOT create a release' do
        it 'return false' do
          expect(subject.run).to eq(false)
        end
      end
    end
  end

  context "when the user is NOT on the same team" do
    let(:user) { create(:user, team: create(:team)) }
    it "returns false" do
      expect(subject.run).to eq(false)
    end
  end
end
