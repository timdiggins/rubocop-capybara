# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Capybara::SpecificActions do
  it 'does not register an offense for find and click action when ' \
     'first argument is link' do
    expect_no_offenses(<<~RUBY)
      find('a').click
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'first argument is link with href' do
    expect_offense(<<~RUBY)
      find('a', href: 'http://example.com').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
      find("a[href='http://example.com']").click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'first argument is button' do
    expect_offense(<<~RUBY)
      find('button').click
      ^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'first argument is button with class' do
    expect_offense(<<~RUBY)
      find('button.cls').click
      ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click action when ' \
     'consecutive chain methods' do
    expect_offense(<<~RUBY)
      find("a").find('button').click
                ^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click action with ' \
     'other argument' do
    expect_offense(<<~RUBY)
      find('button', exact_text: 'foo').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using find and click actions when ' \
     'first argument is multiple selector ` `' do
    expect_offense(<<~RUBY)
      find('div button').click
      ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'does not register an offense for find and click actions when ' \
     'first argument is multiple selector `,`' do
    expect_no_offenses(<<~RUBY)
      find('button,a').click
      find('a, button').click
    RUBY
  end

  it 'does not register an offense for find and click actions when ' \
     'first argument is multiple selector `>`' do
    expect_no_offenses(<<~RUBY)
      find('button>a').click
      find('a > button').click
    RUBY
  end

  it 'does not register an offense for find and click actions when ' \
     'first argument is multiple selector `+`' do
    expect_no_offenses(<<~RUBY)
      find('button+a').click
      find('a + button').click
    RUBY
  end

  it 'does not register an offense for find and click actions when ' \
     'first argument is multiple selector `~`' do
    expect_no_offenses(<<~RUBY)
      find('button~a').click
      find('a ~ button').click
    RUBY
  end

  %i[id class style disabled name value title type].each do |attr|
    it 'registers an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_button`' do
      expect_offense(<<~RUBY, attr: attr)
        find("button[#{attr}=foo]").click
        ^^^^^^^^^^^^^^{attr}^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
      RUBY
    end
  end

  %i[id class style alt title download].each do |attr|
    it 'does not register an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_link` without `href`' do
      expect_no_offenses(<<~RUBY, attr: attr)
        find("a[#{attr}=foo]").click
        find("a[#{attr}]").click
      RUBY
    end

    it 'registers an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_link` with attribute `href`' do
      expect_offense(<<~RUBY, attr: attr)
        find("a[#{attr}=foo][href='http://example.com']").click
        ^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
      RUBY
    end

    it 'registers an offense for abstract action when ' \
       "first argument is element with replaceable attributes #{attr} " \
       'for `click_link` with option `href`' do
      expect_offense(<<~RUBY, attr: attr)
        find("a[#{attr}=foo]", href: 'http://example.com').click
        ^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
        find("a[#{attr}=foo]", text: 'foo', href: 'http://example.com').click
        ^^^^^^^^^{attr}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_link` over `find('a').click`.
      RUBY
    end
  end

  it 'registers an offense when using abstract action with ' \
     'first argument is element with multiple replaceable attributes' do
    expect_offense(<<~RUBY)
      find('button[disabled=true][name="foo"]', exact_text: 'foo').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using abstract action with state' do
    expect_offense(<<~RUBY)
      find('button[disabled=false]', exact_text: 'foo').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using abstract action with ' \
     'first argument is element with replaceable pseudo-classes' do
    expect_offense(<<~RUBY)
      find('button:not([disabled=true])', exact_text: 'bar').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'registers an offense when using abstract action with ' \
     'first argument is element with multiple replaceable pseudo-classes' do
    expect_offense(<<~RUBY)
      find('button:not([disabled=true]):enabled').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
      find('button:not([disabled=false]):disabled').click
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `click_button` over `find('button').click`.
    RUBY
  end

  it 'does not register an offense when using abstract action with' \
     'first argument is element with not replaceable attributes' do
    expect_no_offenses(<<~RUBY)
      find('button[disabled]').click
      find('button[id=some-id][disabled]').click
      find('button[visible]').click
    RUBY
  end

  it 'does not register an offense when using abstract action with ' \
     'first argument is element with replaceable pseudo-classes' \
     'and not boolean attributes' do
    expect_no_offenses(<<~RUBY)
      find('button:not([name="foo"][disabled=true])').click
    RUBY
  end

  it 'does not register an offense when using abstract action with ' \
     'first argument is element with multiple nonreplaceable pseudo-classes' do
    expect_no_offenses(<<~RUBY)
      find('button:first-of-type:not([disabled=true])').click
    RUBY
  end

  it 'does not register an offense for abstract action when ' \
     'first argument is element with nonreplaceable attributes' do
    expect_no_offenses(<<~RUBY)
      find('button[data-disabled=true]').click
      find('button[foo=bar]').click
      find('button[foo-bar=baz]', exact_text: 'foo').click
    RUBY
  end

  it 'does not register an offense for abstract action when ' \
     'first argument is element with multiple nonreplaceable attributes' do
    expect_no_offenses(<<~RUBY)
      find('button[disabled=true][foo=bar]').click
      find('button[foo=bar][disabled=true]').click
      find('button[foo=bar][disabled=true][bar=baz]').click
      find('button[disabled=true][foo=bar]').click
      find('button[disabled=foo][bar=bar]', exact_text: 'foo').click
    RUBY
  end

  it 'does not register an offense for find and click actions when ' \
     'first argument is not a replaceable element' do
    expect_no_offenses(<<~RUBY)
      find('article').click
      find('body').click
    RUBY
  end

  it 'does not register an offense for find and click actions when ' \
     'first argument is not an element' do
    expect_no_offenses(<<~RUBY)
      find('.a').click
      find('#button').click
      find('[a]').click
    RUBY
  end
end
