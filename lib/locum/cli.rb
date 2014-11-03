# encoding: utf-8
require 'thor'
require 'highline/import'
require 'locum'

class Locum::CLI < Thor

  desc 'init', 'Получает token для работы с сервисом'
  option :login
  option :password

  def init
    cn.say("\nНастройка интерфейса командной строки locum.ru\n\n")

    login    = options[:login] || cn.ask('login: ')
    password = options[:password] || cn.ask('пароль: ') { |q| q.echo = false }

    s_out "Получаем токен https://locum.ru"

    authenticator = Locum::Auth.new(login, password)

    authenticator.persist_token

    s_in "Токен получен\n\n"

    cn.say <<EOFBLOCK
    Авторизационный токен для доступа к вашим проектам сохранен в
    текущем каталоге в файле <%= color('.locum', BOLD) %>.
    Возможно, вы не хотите, чтобы этот токен попал в систему контроля
    версий. В этом случае вам нужно добавить исключение в ваш .gitignore
    или его аналог.

    Выданный токен можно отозвать в любой момент через панель управления
    хостингом.

    Интерфейс командной строки настроен, используйте команду
    <%= color('locum help', BOLD) %> для получения списка возможных действий и справки.

EOFBLOCK

  rescue ApiError => e
    display_error(e)
  end

  desc 'ping', 'Проверка связи с API'

  def ping
    s_out "PING"

    ping = Locum::Ping.new
    ping.call

    s_in "PONG login: #{ping.login} till #{ping.valid}\n\n"

  rescue ApiError => e
    display_error(e)
  end

  desc 'projects', 'Список проектов'

  def projects
    projects = Locum::Projects.new
    projects.call

    projects.projects.each {|p| say(" * #{p['name']}") }
  end


  private

  def display_error e
    cn = HighLine.new
    cn.say("\n<%= color('Произошла ошибка:', RED) %> #{e.message}")
  end

  def cn
    @cn ||= HighLine.new
  end

  def s_out(s)
    cn.say("\n<%= color('->', GREEN) %> #{s}")
  end

  def s_in(s)
    cn.say("<%= color('<-', CYAN) %> #{s}")
  end

end
