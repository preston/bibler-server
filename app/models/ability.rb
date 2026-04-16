# frozen_string_literal: true

class Ability
  include CanCan::Ability

  STUDY_NESTED = [StudyVerse, StudyCommentary, StudyQuestion, StudyTask, StudyPlanItem].freeze
  STUDY_RESOURCES = (STUDY_NESTED + [StudyAnswer]).freeze

  def initialize(principal, requested_study_mode: 'participant')
    @requested_study_mode = Study::MODES.include?(requested_study_mode) ? requested_study_mode : 'participant'

    if principal.is_a?(User)
      apply_user_rbac(principal)
      return if principal.effective_permissions[:administrator]

      apply_study_abilities_for_user(principal)
    else
      apply_guest_study_abilities(principal)
    end
  end

  private

  def apply_user_rbac(user)
    perms = user.effective_permissions
    return unless perms

    if perms[:administrator]
      can :manage, :all
      return
    end

    can :manage, Role if perms[:access]
    can :manage, User if perms[:access]
    can :read, Role if perms[:access]
    can :read, User if perms[:access]
    can :manage, :system_ai_settings if perms[:bibles]
    can :read, :system_ai_settings if perms[:bibles]
  end

  def apply_study_abilities_for_user(user)
    perms = user.effective_permissions || {}

    can :read, Study do |study|
      study_readable_by_user?(study, user, perms)
    end

    STUDY_NESTED.each do |klass|
      can :read, klass do |obj|
        study_readable_by_user?(obj.study, user, perms)
      end
    end

    can :read, StudyAnswer do |answer|
      st = answer.study_question&.study
      st ? study_readable_by_user?(st, user, perms) : false
    end

    # Logged-in users may create studies (controller sets owner).
    can :create, Study

    # Private study — owner or curation: full manage (mode header ignored).
    can :manage, STUDY_RESOURCES + [Study] do |resource|
      study = study_from_resource(resource)
      next false unless study

      study.visibility == 'private' && (study.owner_id == user.id || perms[:curation])
    end

    # Non-private — same rules as the original app by mode (header).
    mode = @requested_study_mode
    case mode
    when 'leader'
      can :manage, STUDY_RESOURCES + [Study] do |resource|
        study = study_from_resource(resource)
        study && study.visibility != 'private'
      end
    when 'co-leader'
      can %i[create update destroy], STUDY_NESTED do |resource|
        study = study_from_resource(resource)
        study && study.visibility != 'private'
      end
      can %i[create update], Study do |study|
        study.visibility != 'private'
      end
      allow_answer_create_for_non_private
      allow_answer_update_destroy_for_non_private
    else
      allow_answer_create_for_non_private
      can :update, StudyAnswer do |answer|
        st = answer.study_question&.study
        next false unless st && st.visibility != 'private'

        answer.user_id == user.id
      end
      can :destroy, StudyAnswer do |answer|
        st = answer.study_question&.study
        next false unless st && st.visibility != 'private'

        answer.user_id == user.id
      end
    end
  end

  def apply_guest_study_abilities(principal)
    mode = principal&.study_mode.to_s.presence || 'participant'
    mode = Study::MODES.include?(mode) ? mode : 'participant'

    can :read, Study do |study|
      guest_study_readable?(study)
    end

    STUDY_NESTED.each do |klass|
      can :read, klass do |obj|
        guest_study_readable?(obj.study)
      end
    end

    can :read, StudyAnswer do |answer|
      st = answer.study_question&.study
      st ? guest_study_readable?(st) : false
    end

    case mode
    when 'leader'
      can :manage, STUDY_RESOURCES + [Study] do |resource|
        study = study_from_resource(resource)
        study && guest_study_readable?(study)
      end
      cannot :create, StudyAnswer
      cannot :update, StudyAnswer
      cannot :destroy, StudyAnswer
    when 'co-leader'
      can %i[create update destroy], STUDY_NESTED do |resource|
        study = study_from_resource(resource)
        study && guest_study_readable?(study)
      end
      can %i[create update], Study do |study|
        guest_study_readable?(study)
      end
    else
      # participant guest: read-only on answers; replies require sign-in
    end
  end

  def study_readable_by_user?(study, user, perms)
    return false unless study

    return true if study.visibility != 'private'
    return false unless user.is_a?(User)

    study.owner_id == user.id || perms[:curation]
  end

  def guest_study_readable?(study)
    study && study.visibility != 'private'
  end

  def study_from_resource(resource)
    case resource
    when Study
      resource
    when StudyVerse, StudyCommentary, StudyQuestion, StudyTask, StudyPlanItem
      resource.study
    when StudyAnswer
      resource.study_question&.study
    end
  end

  def allow_answer_create_for_non_private
    can :create, StudyAnswer do |answer|
      st = answer.study_question&.study
      st && st.visibility != 'private'
    end
  end

  def allow_answer_update_destroy_for_non_private
    can :update, StudyAnswer do |answer|
      st = answer.study_question&.study
      st && st.visibility != 'private'
    end
    can :destroy, StudyAnswer do |answer|
      st = answer.study_question&.study
      st && st.visibility != 'private'
    end
  end
end
